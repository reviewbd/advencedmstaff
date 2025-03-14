import os
import json
import asyncio
import websockets
import discord
from discord.ext import commands
from dotenv import load_dotenv

# Chargement des variables d'environnement
load_dotenv()
TOKEN = os.getenv("TOKEN")
GUILD_ID = int(os.getenv("GUILD_ID"))
CHANNEL_ID = int(os.getenv("CHANNEL_ID"))
FIVEM_SOCKET_URL = os.getenv("FIVEM_SOCKET_URL")

# Configuration du bot
intents = discord.Intents.default()
intents.messages = True
intents.guilds = True
intents.message_content = True

bot = commands.Bot(command_prefix="!", intents=intents)

# WebSocket Client pour FiveM
async def connect_to_fivem():
    async with websockets.connect(FIVEM_SOCKET_URL) as ws:
        print("✅ Connecté à FiveM WebSocket")
        while True:
            try:
                data = await ws.recv()
                message = json.loads(data)
                if message.get("event") == "mstaffMessage":
                    await send_to_discord(message["content"], message["sender"])
            except Exception as e:
                print(f"❌ Erreur WebSocket: {e}")
                await asyncio.sleep(5)  # Reconnexion après une erreur

# Envoie un message sur Discord
async def send_to_discord(content, sender):
    channel = bot.get_channel(CHANNEL_ID)
    if channel:
        await channel.send(f"📢 **MStaff** | {sender} : {content}")

# Commande pour envoyer un message vers FiveM
@bot.command()
async def mstaff(ctx, *, message):
    if ctx.channel.id != CHANNEL_ID:
        return
    sender = ctx.author.name
    async with websockets.connect(FIVEM_SOCKET_URL) as ws:
        data = json.dumps({"event": "mstaffMessage", "sender": sender, "content": message})
        await ws.send(data)

# Lancement du bot
@bot.event
async def on_ready():
    print(f"✅ Connecté en tant que {bot.user}")
    asyncio.create_task(connect_to_fivem())

bot.run(TOKEN)
