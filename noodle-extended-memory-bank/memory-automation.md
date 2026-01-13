# Automatische Memory Bank Updates

## Overzicht

Dit document beschrijft de implementatie van automatische updates voor de memory-bank, inclusief indexering van nieuwe files en gebruik van de informatie in de workflow. De setup zorgt ervoor dat de memory-bank altijd up-to-date is en actief wordt gebruikt door rollen en agents.

## Implementatie Details

### Componenten

- **memory-updater.js**: Hoofds script voor het detecteren van changes, updaten van index.json en genereren van changelog.md
- **Git Post-commit Hook**: Automatisch trigger na elke commit via .git/hooks/post-commit
- **Agents Server Integration**: API endpoints voor programmatic access (/api/update-memory, /api/memory-index, /api/changelog)
- **VS Code Tasks**: Tasks in .vscode/tasks.json voor handmatige triggers
- **Package.json Scripts**: "update-memory" en "start-agents" voor npm commands

### Workflow

1. **Bij Commit**: Post-commit hook runt `node memory-updater.js`
2. **File Detection**: Script detecteert new/modified files via simple-git status
3. **Index Update**: memory-bank/index.json wordt bijgewerkt met metadata (added/modified dates, summaries)
4. **Changelog Generation**: memory-bank/changelog.md krijgt nieuwe entry met commit info en affected documents
5. **API Access**: Rollen kunnen via agents-server endpoints de laatste index en changelog ophalen

### Gebruik in Workflow

- **Pre-task Consultation**: Rollen moeten /api/memory-index queryen voor latest knowledge (enforced in AGENTS.md)
- **Solution Integration**: Solution_database.md updates worden automatisch gelogd en geïndexeerd
- **Documentation Sync**: Nieuwe docs in memory-bank worden direct zichtbaar in index
- **Role Assignment**: Project Manager gebruikt changelog voor milestone tracking

## API Endpoints

- **POST /api/update-memory**: Trigger manual update (gebruikt door VS Code tasks)
- **GET /api/memory-index**: Haal volledige index.json op voor search en navigation
- **GET /api/changelog**: Haal changelog.md op voor recente changes review

## VS Code Integration

- **Task "Update Memory Bank"**: Ctrl+Shift+P > Tasks: Run Task > Update Memory Bank
- **Task "Start Agents Server"**: Background task voor agents-server (automatisch bij workspace open)
- **Keyboard Shortcut**: Bind Ctrl+Shift+M aan update-memory task via keybindings.json

## Git Hook Setup

- **Location**: .git/hooks/post-commit
- **Execution**: Automatisch bij elke git commit
- **Error Handling**: Fouten gelogd in console, niet blocking voor commit
- **Windows Compatibility**: Werkt met Git Bash; voor CMD gebruik .bat wrapper indien nodig

## Beheer en Maintenance

- **Dependencies**: simple-git (^3.22.1) voor Git operations
- **Error Recovery**: Script handelt missing files gracefully met fallback logging
- **Performance**: Lichtgewicht, runt <1s voor typical commits
- **Security**: Geen externe inputs; alleen lokale file operations

## Usage Enforcement

Volgens AGENTS.md Update & Maintenance Procedures:

- **Roles must query /api/memory-index before tasks** om latest knowledge te gebruiken
- **Automatic updates ensure single source of truth** voor alle team members
- **Changelog review required** voor major changes door Project Manager

## Troubleshooting

- **Hook niet triggered**: Check `git config core.hooksPath` (moet leeg zijn voor local hooks)
- **Script errors**: Run `npm run update-memory` manually voor debugging
- **Index niet up-to-date**: Force update via API of VS Code task
- **Windows execution issues**: Zorg voor Node.js in PATH; gebruik Git Bash voor hooks

## Toekomstige Verbeteringen

- **AI-powered Summaries**: Gebruik LLM voor automatic content summaries van new files
- **Search Integration**: Full-text search over memory-bank via /api/search endpoint
- **Version History**: Git-based versioning van index.json changes
- **Distributed Sync**: Sync met remote repositories voor team collaboration

*Laatste update: Automatisch gegenereerd op ${new Date().toISOString()}*
