# Run Celestia Light Node with One-command Script

<img src="https://i.ytimg.com/vi/9uL3jZe4mTY/maxresdefault.jpg" width="700"/>

## About Celestia
Celestia is a modular data availability network that securely scales with the number of users, making it easy for anyone to launch their own blockchain.
* [Twitter](https://x.com/CelestiaOrg)
* [Website](https://celestia.org/)
* [Discord](https://discord.com/invite/YsnTPcSfWQ)
* [Docs](https://docs.celestia.org/)
* [Github](https://github.com/celestiaorg)

#### This script allows you to set up and run a `Celestia Light Node` with a single command. Script automatically does the necessary setup, setup the Light node and runs it inside the screen.

## System Requirements

- Memory: 500 MB RAM (minimum)
- CPU: Single Core
- Disk: 100 GB SSD Storage
- Bandwidth: 56 Kbps for Download/56 Kbps for Upload

## About Light Node
Light nodes allow anyone to directly verify data availability and interact with Celestia without centralized gateways or RPC providers. They perform data availability sampling (DAS) on the received headers, ensuring data availability. This is the most common way to interact with Celestia networks and enables Celestia to securely increase throughput for rollups as new light nodes join the network over time.

<div style="text-align: center;">
    <img src="https://docs.celestia.org/img/nodes/LightNodes.png" width="700"/>
</div>

## How to Use?

To use this script, run the following command in your terminal:
```bash
wget -q -O light_kocality.sh https://raw.githubusercontent.com/kocality/celestia-light/main/light_kocality.sh && sudo chmod +x light_kocality.sh && ./light_kocality.sh
```

Note: You can exit the screen with `CTRL A + D`. When you exit in this way, your node will continue to work on the screen. 

### LM🦥
