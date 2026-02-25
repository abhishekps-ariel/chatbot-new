from typing import Optional
from pydantic import Field
from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""
    
    # OpenAI
    openai_api_key: str
    openai_model: str = "gpt-4o-mini"
    openai_embedding_model: str = "text-embedding-3-small"
    
    # Database (optional DATABASE_URL for Render/Heroku-style platforms)
    database_url: Optional[str] = Field(default=None, validation_alias="DATABASE_URL")
    postgres_host: str = "localhost"
    postgres_port: int = 5432
    postgres_db: str = "chatbot_db"
    postgres_user: str = "postgres"
    postgres_password: str = ""
    
    # API (PORT is set by Render; use it when present)
    api_host: str = "0.0.0.0"
    api_port: int = 8002
    
    # CORS
    frontend_url: str = "http://localhost:5173"
    
    # RAG parameters
    chunk_size: int = 1000
    chunk_overlap: int = 200
    top_k_results: int = 5
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = False
    
    @property
    def connection_url(self) -> str:
        """PostgreSQL connection URL (DATABASE_URL or built from postgres_*)."""
        if self.database_url:
            # Render/Heroku use postgres://; SQLAlchemy expects postgresql://
            url = self.database_url
            if url.startswith("postgres://"):
                url = "postgresql://" + url[len("postgres://") :]
            return url
        return (
            f"postgresql://{self.postgres_user}:{self.postgres_password}"
            f"@{self.postgres_host}:{self.postgres_port}/{self.postgres_db}"
        )


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()
