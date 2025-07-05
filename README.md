# RuneScape 3 Bot Farm Monitoring System

## 🖥️ System Overview
This monitoring solution consists of:
1. **Lua Client Script** - Runs within your RuneScape bots
2. **Python Web Server** - Collects and serves monitoring data
3. **Web Dashboard** - Real-time visualization of bot farm status

## 📂 File Placement Guide

### 1. Lua Monitoring Script (`bot_monitor.lua`)
- **Required Location:**  
  `C:\Users\%USERPROFILE%\MemoryError\lua scripts\bot_monitor.lua`  
  *(Example: `C:\Users\JohnDoe\MemoryError\lua scripts\bot_monitor.lua`)*

### 2. Python Server Files
Your_Project_Directory/
├── app.py # Main server application
└── templates/ # REQUIRED folder name
└── dashboard.html # Dashboard interface

## ⚙️ Setup Instructions

### Prerequisites
- [Python 3.10 or newer](https://www.python.org/downloads/)
- MemoryError Lua environment for bot scripts

### Step 1: Install Python Dependencies
```cmd
pip install Flask Flask-SQLAlchemy
```
Integrate with Bot Script

Add this to your bot's main script before the main loop:
-- Load monitoring module
local botMonitor = require("bot_monitor")

-- MANDATORY FOR WEALTH TRACKING
```
local function openWealthEvaluator()
    -- IMPLEMENT YOUR WEALTH OPENING LOGIC HERE
    -- Example: open_interface("wealth_evaluator")
    -- Must be called BEFORE startMonitoring()
end

-- Initialize monitoring
openWealthEvaluator()  -- Required for wealth tracking
botMonitor.startMonitoring()
```

Starting the System

Start your bot farm as normal

Launch the monitoring server:
```
cd "C:\path_to_your_project_directory"
python app.py
```
Access dashboard at:
http://localhost:5000

📊 Dashboard Features

    Real-time bot status monitoring

    Wealth tracking (GP/hour estimates)

    Activity timeline

    Error rate tracking

    Resource utilization metrics

    Interactive bot selection

🔧 Troubleshooting Guide
Issue	Solution
Lua module not found	Verify exact path: ...\lua scripts\bot_monitor.lua
Dashboard not loading	Check firewall allows port 5000
Wealth shows 0	1. Confirm openWealthEvaluator() implementation
2. Verify call order (before startMonitoring)
3. Check wealth interface is visible
No bot data	1. Confirm bots are running
2. Verify Lua integration
3. Check network connectivity

🔄 Update Procedure

    Stop all running bots

    Stop Python server (Ctrl+C in terminal)

    Replace old files with new versions

    Restart bots

    Restart server: python app.py

📌 Important Notes

    Server must run while bots are active

    Bots must remain logged in for monitoring

    Wealth evaluator must be open in-game for GP tracking

    Data updates every 30 seconds by default

    Keep Python server terminal open during operation

📈 Recommended Monitoring Practices

    Start server before launching bots

    Verify dashboard connection when first bot starts

    Use wealth tracking during money-making activities

    Monitor error rates for script debugging

    Check dashboard regularly for disconnections
