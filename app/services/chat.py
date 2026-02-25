from openai import OpenAI
from typing import List, Tuple, Dict
import re
from app.config import get_settings
from app.models import DocumentChunk

settings = get_settings()
client = OpenAI(api_key=settings.openai_api_key)


class ChatService:
    """Service for generating answers using OpenAI."""
    
    def __init__(self):
        self.model = settings.openai_model
    
    def generate_answer(
        self,
        question: str,
        context_chunks: List[Tuple[DocumentChunk, float]],
        conversation_history: List[Dict[str, str]] = None
    ) -> str:
        """
        Generate answer using retrieved context and OpenAI.
        
        Args:
            question: User's question
            context_chunks: List of (DocumentChunk, similarity_score) tuples
            
        Returns:
            Generated answer
        """
        # Build context from chunks
        context = self._build_context(context_chunks)
        
        # Extract video links only if chunks are highly relevant (similarity > 0.6)
        video_links = []
        if context_chunks and context_chunks[0][1] > 0.6:  # Check top result's similarity
            video_links = self._extract_video_links(context)
        
        # Create system message
        system_message = """You are an intelligent AI assistant that helps users with their questions.

Your role:
- Provide accurate, helpful answers based on the available information
- Be conversational, friendly, and professional
- Keep answers brief (2-4 sentences max) unless more detail is requested
- Use bullet points for steps or lists to improve readability
- Never mention "context", "documents", "provided information", or reveal that you're using retrieved data
- If you don't have enough information, politely acknowledge and suggest what you can help with
- For greetings like "hi" or "hello", respond warmly and ask how you can help
- Prioritize natural dialogue and helpfulness
- Remember previous messages in the conversation to provide contextual follow-up answers
- Avoid robotic or overly enumerated responses unless asked"""

        user_message = f"""Use this information to answer:
{context}

User question: {question}

Your response (be natural, helpful, and BRIEF):"""
        
        # Build messages list with conversation history
        messages = [{"role": "system", "content": system_message}]
        
        # Add conversation history (last 10 messages max)
        if conversation_history:
            history_messages = conversation_history[-10:]  # Keep last 10 only
            for msg in history_messages:
                messages.append({"role": msg["role"], "content": msg["content"]})
        
        # Add current user message
        messages.append({"role": "user", "content": user_message})
        
        # Call OpenAI
        try:
            response = client.chat.completions.create(
                model=self.model,
                messages=messages,
                temperature=0.7,
                max_tokens=500
            )
            answer = response.choices[0].message.content.strip()
            
            # Append video links if found
            if video_links:
                answer += "\n\n📹 Related videos:\n" + "\n".join(video_links)
            
            return answer
        except Exception as e:
            raise ValueError(f"Failed to generate answer: {str(e)}")
    
    def _extract_video_links(self, context: str) -> List[str]:
        """Extract YouTube/video links from context."""
        # Pattern to match YouTube links and other video URLs
        pattern = r'https?://(?:www\.)?(?:youtube\.com/watch\?v=|youtu\.be/)[\w-]+|https?://[^\s]+\.(?:mp4|avi|mov)'
        links = re.findall(pattern, context)
        return list(set(links))  # Remove duplicates
    
    def _build_context(self, chunks: List[Tuple[DocumentChunk, float]]) -> str:
        """Build context string from chunks."""
        if not chunks:
            return "No relevant context found."
        
        context_parts = []
        for i, (chunk, score) in enumerate(chunks, 1):
            context_parts.append(
                f"[Source {i} - {chunk.document_name} (Relevance: {score:.2f})]:\n{chunk.chunk_text}"
            )
        
        return "\n\n".join(context_parts)
