"""
NIP v3.0.0 - Interactive Web UI
A modern, production-ready Streamlit application for the NIP AI Assistant
"""

import os
import sys
import json
import asyncio
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Optional, Generator
import time

import streamlit as st
from streamlit_option_menu import option_menu
import httpx
from dotenv import load_dotenv
import pandas as pd

# Add parent directory to path for imports
parent_dir = Path(__file__).parent.parent
sys.path.insert(0, str(parent_dir))

# Load environment variables
load_dotenv()

# Page configuration
st.set_page_config(
    page_title="NIP v3.0.0",
    page_icon="🤖",
    layout="wide",
    initial_sidebar_state="expanded",
)

# Custom CSS for modern, beautiful UI
def load_custom_css(theme: str = "dark") -> None:
    """Load custom CSS for styling"""
    
    if theme == "dark":
        bg_color = "#0e1117"
        text_color = "#fafafa"
        card_bg = "#1a1d24"
        border_color = "#2d3039"
        accent_color = "#4a9eff"
    else:
        bg_color = "#ffffff"
        text_color = "#0e1117"
        card_bg = "#f0f2f6"
        border_color = "#e0e0e0"
        accent_color = "#0066cc"
    
    css = f"""
    <style>
        /* Main container */
        .main {{
            background-color: {bg_color};
        }}
        
        /* Chat messages */
        .chat-message {{
            padding: 1.2rem;
            border-radius: 0.8rem;
            margin-bottom: 1rem;
            display: flex;
            flex-direction: column;
            animation: fadeIn 0.3s ease-in;
        }}
        
        @keyframes fadeIn {{
            from {{ opacity: 0; transform: translateY(10px); }}
            to {{ opacity: 1; transform: translateY(0); }}
        }}
        
        .user-message {{
            background-color: {accent_color};
            color: white;
            margin-left: 2rem;
            border-bottom-right-radius: 0.2rem;
        }}
        
        .assistant-message {{
            background-color: {card_bg};
            color: {text_color};
            margin-right: 2rem;
            border-bottom-left-radius: 0.2rem;
            border: 1px solid {border_color};
        }}
        
        .system-message {{
            background-color: transparent;
            color: #888;
            font-style: italic;
            text-align: center;
            margin: 0.5rem 0;
        }}
        
        /* Code blocks */
        .code-block {{
            background-color: #1e1e1e;
            color: #d4d4d4;
            padding: 1rem;
            border-radius: 0.5rem;
            overflow-x: auto;
            font-family: 'Consolas', 'Monaco', monospace;
            font-size: 0.9rem;
            margin: 0.5rem 0;
            border: 1px solid #333;
        }}
        
        /* Input area */
        .chat-input-container {{
            position: fixed;
            bottom: 0;
            left: 0;
            right: 0;
            padding: 1rem 2rem;
            background-color: {card_bg};
            border-top: 1px solid {border_color};
            z-index: 999;
        }}
        
        /* Sidebar styling */
        .sidebar {{
            background-color: {card_bg};
        }}
        
        /* Cards */
        .info-card {{
            background-color: {card_bg};
            padding: 1.5rem;
            border-radius: 0.8rem;
            border: 1px solid {border_color};
            margin-bottom: 1rem;
            transition: transform 0.2s, box-shadow 0.2s;
        }}
        
        .info-card:hover {{
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }}
        
        /* Buttons */
        .stButton > button {{
            border-radius: 0.5rem;
            transition: all 0.2s;
            font-weight: 500;
        }}
        
        .stButton > button:hover {{
            transform: scale(1.02);
        }}
        
        /* Progress bar */
        .stProgress > div > div > div > div {{
            background-color: {accent_color};
        }}
        
        /* File uploader */
        .uploadedFile {{
            border: 2px dashed {border_color};
            border-radius: 0.8rem;
            padding: 2rem;
            text-align: center;
        }}
        
        /* Syntax highlighting */
        .highlight {{
            background-color: #fff3cd;
            padding: 0.1rem 0.3rem;
            border-radius: 0.2rem;
        }}
        
        /* Metrics */
        .metric-container {{
            background-color: {card_bg};
            padding: 1rem;
            border-radius: 0.8rem;
            border: 1px solid {border_color};
            text-align: center;
        }}
        
        /* Animations */
        .pulse {{
            animation: pulse 2s infinite;
        }}
        
        @keyframes pulse {{
            0%, 100% {{ opacity: 1; }}
            50% {{ opacity: 0.5; }}
        }}
        
        /* Scrollbar */
        ::-webkit-scrollbar {{
            width: 8px;
        }}
        
        ::-webkit-scrollbar-track {{
            background: {bg_color};
        }}
        
        ::-webkit-scrollbar-thumb {{
            background: {border_color};
            border-radius: 4px;
        }}
        
        ::-webkit-scrollbar-thumb:hover {{
            background: {accent_color};
        }}
    </style>
    """
    st.markdown(css, unsafe_allow_html=True)


class NIPClient:
    """Client for communicating with NIP API"""
    
    def __init__(self, base_url: str = "http://localhost:8000"):
        self.base_url = base_url
        self.timeout = 120.0
    
    async def send_message(
        self,
        message: str,
        conversation_id: Optional[str] = None,
        files: Optional[List[Dict]] = None,
        stream: bool = True
    ) -> Generator[str, None, None]:
        """Send message to NIP API with streaming support"""
        
        payload = {
            "message": message,
            "conversation_id": conversation_id,
            "files": files or [],
            "stream": stream
        }
        
        try:
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                if stream:
                    async with client.stream(
                        "POST",
                        f"{self.base_url}/api/chat",
                        json=payload
                    ) as response:
                        if response.status_code == 200:
                            async for chunk in response.aiter_text():
                                if chunk:
                                    yield chunk
                        else:
                            yield f"❌ Error: {response.status_code}"
                else:
                    response = await client.post(
                        f"{self.base_url}/api/chat",
                        json=payload
                    )
                    if response.status_code == 200:
                        yield response.json().get("response", "")
                    else:
                        yield f"❌ Error: {response.status_code}"
        except Exception as e:
            yield f"❌ Connection Error: {str(e)}\n\nMake sure NIP server is running at {self.base_url}"


def render_message(role: str, content: str, timestamp: Optional[str] = None) -> None:
    """Render a chat message with appropriate styling"""
    
    message_class = f"{role}-message"
    
    if role == "user":
        icon = "👤"
        label = "You"
    elif role == "assistant":
        icon = "🤖"
        label = "NIP"
    else:
        icon = "ℹ️"
        label = "System"
    
    # Format timestamp
    time_str = timestamp or datetime.now().strftime("%H:%M:%S")
    
    # Check if content contains code blocks
    has_code = "```" in content
    
    st.markdown(f"""
    <div class="chat-message {message_class}">
        <div style="display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.5rem; font-weight: 600;">
            <span>{icon}</span>
            <span>{label}</span>
            <span style="opacity: 0.6; font-size: 0.85rem; font-weight: normal;">{time_str}</span>
        </div>
        <div style="line-height: 1.6;">
            {content if not has_code else content}
        </div>
    </div>
    """, unsafe_allow_html=True)


def sidebar_configuration() -> Dict:
    """Render sidebar configuration panel"""
    
    with st.sidebar:
        st.title("⚙️ Configuration")
        st.markdown("---")
        
        # API Configuration
        st.subheader("🔑 API Settings")
        
        api_url = st.text_input(
            "API URL",
            value=os.getenv("NIP_API_URL", "http://localhost:8000"),
            help="Base URL for NIP API"
        )
        
        api_key = st.text_input(
            "API Key",
            value=os.getenv("NIP_API_KEY", ""),
            type="password",
            help="Optional API key for authentication"
        )
        
        st.markdown("---")
        
        # Model Settings
        st.subheader("🧠 Model Settings")
        
        model = st.selectbox(
            "Model",
            options=["gpt-4", "gpt-4-turbo", "gpt-3.5-turbo", "claude-3-opus", "claude-3-sonnet"],
            index=0,
            help="Select the AI model to use"
        )
        
        temperature = st.slider(
            "Temperature",
            min_value=0.0,
            max_value=2.0,
            value=0.7,
            step=0.1,
            help="Controls randomness in responses"
        )
        
        max_tokens = st.number_input(
            "Max Tokens",
            min_value=100,
            max_value=32000,
            value=4000,
            step=100,
            help="Maximum tokens in response"
        )
        
        st.markdown("---")
        
        # UI Settings
        st.subheader("🎨 UI Settings")
        
        theme = st.selectbox(
            "Theme",
            options=["dark", "light"],
            index=0,
            help="Choose dark or light theme"
        )
        
        stream_responses = st.checkbox(
            "Stream Responses",
            value=True,
            help="Show responses as they're generated"
        )
        
        show_thinking = st.checkbox(
            "Show Thinking",
            value=False,
            help="Display AI reasoning process"
        )
        
        st.markdown("---")
        
        # Advanced Settings
        with st.expander("🔧 Advanced Settings"):
            timeout = st.number_input(
                "Request Timeout (seconds)",
                min_value=10,
                max_value=300,
                value=120,
                step=10
            )
            
            retry_attempts = st.number_input(
                "Retry Attempts",
                min_value=0,
                max_value=5,
                value=3,
                step=1
            )
            
            debug_mode = st.checkbox(
                "Debug Mode",
                value=False,
                help="Enable debug logging"
            )
        
        st.markdown("---")
        
        # Session Info
        st.subheader("📊 Session Info")
        
        if "conversation_id" in st.session_state:
            st.text_input(
                "Conversation ID",
                value=st.session_state.conversation_id,
                disabled=True,
                help="Current conversation identifier"
            )
        
        message_count = len(st.session_state.get("messages", []))
        st.metric("Messages", message_count)
        
        # Save configuration to session state
        config = {
            "api_url": api_url,
            "api_key": api_key,
            "model": model,
            "temperature": temperature,
            "max_tokens": max_tokens,
            "theme": theme,
            "stream_responses": stream_responses,
            "show_thinking": show_thinking,
            "timeout": timeout,
            "retry_attempts": retry_attempts,
            "debug_mode": debug_mode,
        }
        
        # Save button
        if st.button("💾 Save Configuration", use_container_width=True):
            st.session_state.config = config
            st.success("✅ Configuration saved!")
            time.sleep(1)
        
        return config


def render_file_upload() -> Optional[List[Dict]]:
    """Render file upload section"""
    
    st.markdown("### 📎 Attach Files")
    
    uploaded_files = st.file_uploader(
        "Upload code files for analysis",
        type=["py", "js", "ts", "java", "cpp", "c", "go", "rs", "txt", "md", "json", "yaml"],
        accept_multiple_files=True,
        help="Select files to analyze with NIP"
    )
    
    files_data = []
    if uploaded_files:
        for file in uploaded_files:
            try:
                content = file.read().decode("utf-8")
                files_data.append({
                    "name": file.name,
                    "content": content,
                    "size": len(content),
                    "type": file.name.split(".")[-1]
                })
            except Exception as e:
                st.error(f"❌ Error reading {file.name}: {str(e)}")
        
        if files_data:
            st.success(f"✅ {len(files_data)} file(s) ready for analysis")
            for file_info in files_data:
                with st.expander(f"📄 {file_info['name']} ({file_info['size']} bytes)"):
                    st.code(file_info['content'][:500], language=file_info['type'])
                    if len(file_info['content']) > 500:
                        st.caption(f"... and {len(file_info['content']) - 500} more characters")
    
    return files_data if files_data else None


def export_conversation(messages: List[Dict], format: str = "json") -> str:
    """Export conversation to specified format"""
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    if format == "json":
        data = {
            "conversation_id": st.session_state.get("conversation_id", "unknown"),
            "exported_at": datetime.now().isoformat(),
            "messages": messages,
            "config": st.session_state.get("config", {})
        }
        return json.dumps(data, indent=2)
    
    elif format == "markdown":
        md = f"# NIP Conversation\n\n"
        md += f"**Date:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n"
        md += f"**Conversation ID:** {st.session_state.get('conversation_id', 'unknown')}\n\n"
        md += "---\n\n"
        
        for msg in messages:
            role = msg.get("role", "unknown")
            content = msg.get("content", "")
            timestamp = msg.get("timestamp", "")
            
            md += f"## {role.title()}\n"
            md += f"_{timestamp}_\n\n"
            md += f"{content}\n\n"
        
        return md
    
    elif format == "txt":
        txt = f"NIP Conversation - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n"
        txt += f"Conversation ID: {st.session_state.get('conversation_id', 'unknown')}\n"
        txt += "=" * 80 + "\n\n"
        
        for msg in messages:
            role = msg.get("role", "unknown").upper()
            content = msg.get("content", "")
            
            txt += f"[{role}]\n{content}\n\n"
        
        return txt
    
    return ""


def main():
    """Main application"""
    
    # Initialize session state
    if "messages" not in st.session_state:
        st.session_state.messages = []
    
    if "conversation_id" not in st.session_state:
        st.session_state.conversation_id = f"conv_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    
    if "config" not in st.session_state:
        st.session_state.config = {}
    
    # Get configuration from sidebar
    config = sidebar_configuration()
    
    # Apply theme
    load_custom_css(config.get("theme", "dark"))
    
    # Main content area
    main_container = st.container()
    
    with main_container:
        # Header
        col1, col2, col3 = st.columns([2, 1, 1])
        
        with col1:
            st.title("🤖 NIP v3.0.0")
            st.caption("Intelligent Programming Assistant")
        
        with col2:
            # Clear chat button
            if st.button("🗑️ Clear Chat", use_container_width=True):
                st.session_state.messages = []
                st.session_state.conversation_id = f"conv_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
                st.rerun()
        
        with col3:
            # Export dropdown
            export_format = st.selectbox(
                "Export",
                options=["", "json", "markdown", "txt"],
                label_visibility="collapsed"
            )
            
            if export_format and st.session_state.messages:
                exported_data = export_conversation(st.session_state.messages, export_format)
                st.download_button(
                    label=f"⬇️ Download .{export_format}",
                    data=exported_data,
                    file_name=f"nip_conversation_{datetime.now().strftime('%Y%m%d_%H%M%S')}.{export_format}",
                    mime=f"application/{export_format}",
                    use_container_width=True
                )
        
        st.markdown("---")
        
        # Tabs
        tab1, tab2, tab3 = st.tabs(["💬 Chat", "📁 Files", "📜 History"])
        
        with tab1:
            # Chat interface
            chat_container = st.container()
            
            with chat_container:
                # Display message history
                for message in st.session_state.messages:
                    render_message(
                        message["role"],
                        message["content"],
                        message.get("timestamp")
                    )
            
            # File upload section (collapsible)
            with st.expander("📎 Upload Files for Analysis", expanded=False):
                files_data = render_file_upload()
            
            # Chat input
            st.markdown("<br><br>", unsafe_allow_html=True)  # Spacer
            
            user_input = st.text_area(
                "Message",
                placeholder="Ask NIP anything about your code...",
                height=100,
                label_visibility="collapsed"
            )
            
            col_send, col_clear = st.columns([1, 4])
            
            with col_send:
                send_button = st.button("🚀 Send", use_container_width=True, type="primary")
            
            with col_clear:
                if st.button("🔄 Regenerate Last Response", use_container_width=True):
                    if st.session_state.messages and len(st.session_state.messages) >= 2:
                        # Remove last assistant message
                        if st.session_state.messages[-1]["role"] == "assistant":
                            st.session_state.messages.pop()
                        
                        # Get last user message
                        last_user_msg = st.session_state.messages[-1]["content"]
                        st.rerun()
            
            # Handle send
            if send_button and user_input.strip():
                # Add user message
                timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                st.session_state.messages.append({
                    "role": "user",
                    "content": user_input,
                    "timestamp": timestamp
                })
                
                # Display user message
                render_message("user", user_input, timestamp)
                
                # Create placeholder for assistant response
                response_placeholder = st.empty()
                response_placeholder.markdown("""
                <div class="chat-message assistant-message pulse">
                    <div style="display: flex; align-items: center; gap: 0.5rem;">
                        <span>🤖</span>
                        <span>NIP</span>
                        <span style="opacity: 0.6; font-size: 0.85rem;">Thinking...</span>
                    </div>
                    <div style="margin-top: 1rem;">
                        <span class="pulse">Processing your request...</span>
                    </div>
                </div>
                """, unsafe_allow_html=True)
                
                # Simulate AI response (in production, call actual API)
                time.sleep(1)
                
                # For demo, create a response
                assistant_response = f"""I've received your message: "{user_input}"

In a production environment, I would:
1. Process your request through the NIP API
2. Analyze any uploaded files
3. Generate a helpful response
4. Stream the response in real-time

**Current Status:** Demo Mode
To use the full functionality, ensure the NIP API server is running at: {config['api_url']}

**Configuration:**
- Model: {config['model']}
- Temperature: {config['temperature']}
- Max Tokens: {config['max_tokens']}

Would you like me to help you with something specific?"""
                
                # Update with assistant response
                timestamp_assistant = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                st.session_state.messages.append({
                    "role": "assistant",
                    "content": assistant_response,
                    "timestamp": timestamp_assistant
                })
                
                response_placeholder.empty()
                render_message("assistant", assistant_response, timestamp_assistant)
                
                # Rerun to show updated state
                st.rerun()
        
        with tab2:
            st.subheader("📁 File Analysis")
            
            if files_data if 'files_data' in locals() else False:
                st.info("📊 Files uploaded and ready for analysis")
                
                for file_info in files_data:
                    with st.expander(f"📄 {file_info['name']}", expanded=True):
                        col1, col2 = st.columns([3, 1])
                        
                        with col1:
                            st.code(file_info['content'], language=file_info['type'])
                        
                        with col2:
                            st.markdown("**File Info**")
                            st.write(f"Size: {file_info['size']} bytes")
                            st.write(f"Type: {file_info['type']}")
                            
                            if st.button(f"Analyze {file_info['name']}", key=file_info['name']):
                                st.info("🔍 Analysis will be available in production mode")
            else:
                st.info("📭 No files uploaded yet. Use the chat tab to upload files for analysis.")
        
        with tab3:
            st.subheader("📜 Conversation History")
            
            if not st.session_state.messages:
                st.info("📭 No conversation history yet. Start chatting!")
            else:
                # Create summary statistics
                user_msgs = [m for m in st.session_state.messages if m["role"] == "user"]
                assistant_msgs = [m for m in st.session_state.messages if m["role"] == "assistant"]
                
                col1, col2, col3 = st.columns(3)
                col1.metric("Total Messages", len(st.session_state.messages))
                col2.metric("Your Messages", len(user_msgs))
                col3.metric("NIP Responses", len(assistant_msgs))
                
                st.markdown("---")
                
                # Display history as expandable items
                for i, message in enumerate(reversed(st.session_state.messages), 1):
                    role_icon = "👤" if message["role"] == "user" else "🤖"
                    role_label = message["role"].title()
                    timestamp = message.get("timestamp", "Unknown")
                    
                    with st.expander(f"{role_icon} {role_label} - {timestamp}"):
                        st.markdown(message["content"])


if __name__ == "__main__":
    main()
