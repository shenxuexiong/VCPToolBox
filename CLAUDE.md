# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

VCP (Variable & Command Protocol) is an AI middleware layer that sits between AI models and frontend applications. It provides tools, memory systems (RAG/diary), and agent capabilities through a plugin-based architecture.

**Key Philosophy**: VCP treats AI as an equal "creator partner" rather than a passive tool, using a natural language-based tool protocol (`<<<[TOOL_REQUEST]>>>`) instead of rigid JSON function calling.

## Architecture

The project uses a flat root directory structure (no `src/` folder). Key files by responsibility:

| File | Purpose |
|------|---------|
| `server.js` | Main HTTP/SSE entry point, startup orchestration, middleware setup |
| `Plugin.js` | Plugin lifecycle: loading, execution, configuration merging |
| `WebSocketServer.js` | Distributed node communication and tool bridging |
| `KnowledgeBaseManager.js` | RAG system, vector indexes, diary management |
| `modules/messageProcessor.js` | Variable substitution, prompt injection pipeline |
| `modules/agentManager.js` | Agent file mapping, hot-reload watching |
| `modules/chatCompletionHandler.js` | Chat completion main flow orchestration |
| `routes/` | Express route handlers |
| `Plugin/` | 79+ active plugins (Node.js/Python/Rust) |
| `Agent/` | Agent prompt files (`.txt` format) |
| `rust-vexus-lite/` | Rust N-API vector engine (requires building) |
| `TVStxt/` | Advanced prompt templates and placeholder combinations |

## Common Commands

### First-time Setup
```bash
# Install dependencies
npm install
pip install -r requirements.txt

# Build Rust vector engine (REQUIRED before first run)
cd rust-vexus-lite
npm run build    # Release build
cd ..

# Configuration
cp config.env.example config.env
# Edit config.env with your API keys
```

### Running
```bash
# Development
node server.js

# Production (with PM2)
pm2 start server.js
pm2 logs

# Docker (recommended for production)
docker-compose up --build -d
docker-compose logs -f
```

### Testing
```bash
# No formal test suite - project uses production validation
# The test-units.js file contains ad-hoc tests for specific modules
```

## Plugin System

### Plugin Types
- **static**: One-shot execution, returns output immediately
- **messagePreprocessor**: Modifies messages before sending to AI
- **synchronous**: Blocking execution with stdio communication
- **asynchronous**: Long-running tasks with callback notification
- **service**: Long-running background processes
- **hybridservice**: Combination of service and static capabilities

### Plugin Structure
Each plugin has a `plugin-manifest.json`:
```json
{
  "name": "PluginName",
  "pluginType": "synchronous",
  "entryPoint": {
    "type": "nodejs",
    "command": "node plugin.js"
  },
  "capabilities": {
    "invocationCommands": [...]
  }
}
```

### Disabling Plugins
Rename `plugin-manifest.json` to `plugin-manifest.json.block`

## VCP Tool Protocol

VCP uses a custom text-based protocol (not OpenAI function calling):
```
<<<[TOOL_REQUEST]>>>
tool_name:「始」PluginName「末」,
command:「始」commandName「末」,
param1:「始」value1「末」
<<<[END_TOOL_REQUEST]>>>
```

The `「始」「末」` (start/end) delimiters provide robust parsing that tolerates AI formatting variations.

## Variable Substitution System

Supports four variable types loaded from different sources:
- `{{AgentName}}` - From `Agent/*.txt` files
- `{{Tar:*}}` - Target/context variables
- `{{Var:*}}` - Custom variables
- `{{Sar:*}}` - System variables
- `{{VCP...}}` - Static plugin placeholders

Files in `TVStxt/` can be loaded as variables using the TVS (TVStxt) system.

## Configuration

- Main config: `config.env` (use `config.env.example` as template)
- Plugin-specific config: In plugin directory
- Environment variables are loaded via dotenv

Critical settings:
- `API_Key`, `API_URL` - Backend AI service
- `PORT` - VCP server port (default: 6005)
- `Key`, `Image_Key`, `File_Key` - Access passwords
- `DebugMode` - Enable debug logging
- `EnableRoleDivider` - Enable context splitting feature

## Memory System (TagMemo/RAG)

- **Diary storage**: `dailynote/` directory
- **Vector indexes**: `VectorStore/` directory (uses `.usearch` format)
- **Semantic groups**: Configured via RAGDiaryPlugin
- **Knowledge base**: SQLite database with embedded metadata

## Agent System

- Agent prompts are stored as `.txt` files in `Agent/` directory
- Alias mapping via `agent_map.json`
- Agents support recursive composition (agents can include other agents)
- Hot-reload: Changes to agent files trigger automatic reload

## Multi-Runtime Architecture

The project supports three runtime environments:
- **Node.js**: Primary (server, most plugins)
- **Python**: Via child_process (some plugins like ComfyUIGen)
- **Rust**: N-API module in `rust-vexus-lite/` for vector operations

## Important Patterns

1. **Flat structure**: Code is at root level, not buried in `src/`
2. **Manifest-driven**: All plugin behavior defined in `plugin-manifest.json`
3. **Async-first**: Most operations use promises/async-await
4. **Error handling**: Many operations have timeout handling and retry logic
5. **Security**: Shell execution paths require careful review

## Anti-Patterns to Avoid

- Don't commit real API keys (`config.env`, plugin configs)
- Don't treat `dailynote/`, `image/`, or plugin `state/` as stable source
- Don't modify plugin manifest critical fields arbitrarily
- Don't add new shell execution paths without strict input validation
- Don't assume CI will run tests (production validation only)
- Don't directly enable `.block` plugins without checking dependencies

## Documentation

The `docs/` directory contains comprehensive documentation:
- `ARCHITECTURE.md` - System architecture and startup sequence
- `PLUGIN_ECOSYSTEM.md` - Plugin types and manifest schema
- `MEMORY_SYSTEM.md` - TagMemo algorithm and RAG system
- `API_ROUTES.md` - HTTP endpoints and authentication
- `CONFIGURATION.md` - Configuration parameters and semantics
- `DISTRIBUTED_ARCHITECTURE.md` - WebSocket protocol for distributed nodes

## Security Considerations

- This system has system-level permissions (file access, shell execution, network)
- The `Plugin/UserAuth/code.bin` file contains encrypted auth codes
- Admin panel uses basic auth (`AdminUsername`, `AdminPassword`)
- Some plugins execute arbitrary commands (review carefully before adding new ones)
