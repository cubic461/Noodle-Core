# NoodleNet

NoodleNet is het zelforganiserende mesh-netwerk dat vormt de kerninfrastructuur voor gedistribueerde computing in NoodleCore. Het zorgt voor:

- Automatische node discovery
- Betrouwbare communicatie tussen nodes
- Slimme taakverdeling over het netwerk
- Zelfoptimalisatie op basis van workload

## Architectuur

NoodleNet bestaat uit vier hoofdcomponenten:

1. **NoodleLink**: Transportlaag voor berichtverzending en ontvangst
2. **NoodleDiscovery**: Node discovery via multicast en gossip
3. **NoodleIdentity**: Unieke node identificatie
4. **NoodleMesh**: Dynamische mesh-topologie met routing

## Snel Start

```python
import asyncio
from noodlenet import NoodleLink, NoodleDiscovery

async def main():
    # Initialiseer netwerkcomponenten
    link = NoodleLink(port=4040)
    discovery = NoodleDiscovery(link)
    
    # Start discovery
    await discovery.broadcast_hello()
    
    # Verstuur een bericht
    await link.send("node_id", b"Hello, NoodleNet!")
    
    # Luister naar berichten
    async for message in link.receive():
        print(f"Received: {message}")

asyncio.run(main())
```

## Documentatie

- [API Referentie](docs/api.md)
- [Configuratie](docs/config.md)
- [Voorbeelden](examples/)
- [Roadmap](ROADMAP.md)

## Licentie

MIT License - zie LICENSE bestand voor details.
