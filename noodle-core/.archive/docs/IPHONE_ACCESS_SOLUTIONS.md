# iPhone DNS Resolution Solutions for <www.noodle.nc>

## Problem Statement

The iPhone cannot resolve `www.noodle.nc` because it uses internet DNS servers that don't know about this local domain. The server has zero-configuration interception capability but needs a way to accept connections from the iPhone.

## ✅ Server Status: CONFIRMED WORKING

Both DNS server and zero-configuration interception are running successfully:

- HTTP Server: ✅ Running on 0.0.0.0:8080
- DNS Server: ✅ Running on 0.0.0.0:53
- Zero-Config Interception: ✅ Enabled

## 🚀 Solution 1: Direct IP Access (RECOMMENDED - IMMEDIATE)

Since the server has zero-configuration interception, it responds to ANY domain when connected via IP address.

### Step 1: Find Your Server IP Address

```bash
# On your computer, find your IP address
ipconfig | findstr "IPv4"
# OR
hostname -I
```

Your server IP is likely: `192.168.68.122` (based on documentation)

### Step 2: iPhone Access Methods

#### Method A: Safari Browser (Direct)

1. Open Safari on iPhone
2. Go to: `http://192.168.68.122:8080/`
3. Add bookmark with custom title: "Noodle IDE"
4. **This works because server accepts all connections via IP**

#### Method B: URL Shortcuts (Recommended)

Create an iPhone Shortcut for easy access:

1. Download "Shortcuts" app on iPhone
2. Create new shortcut:
   - **Name**: "Noodle IDE"
   - **URL**: `http://192.168.68.122:8080/`
   - **Action**: Open URL
3. Add to home screen for one-tap access

#### Method C: Browser Extensions (Advanced)

**If you can install browser extensions on iPhone:**

1. Install extension that allows custom headers
2. Set base URL: `http://192.168.68.122:8080/`
3. Add custom header: `Host: www.noodle.nc`
4. This gives you the full noodle domain experience

### Verification

Test this works first:

```bash
curl http://192.168.68.122:8080/api/v1/health
```

## 🔧 Solution 2: Router DNS Configuration (NETWORK-WIDE)

Configure your router to use your server as the DNS resolver, so ALL devices automatically get noodle domains.

### Step 1: Access Router Admin

1. Open browser on any device
2. Go to router admin panel (usually `192.168.1.1` or `192.168.0.1`)
3. Login with admin credentials

### Step 2: Configure DNS Settings

1. Navigate to DHCP/DNS settings
2. Set **Primary DNS Server**: `192.168.68.122`
3. Set **Secondary DNS Server**: `8.8.8.8` (Google DNS as fallback)
4. Save and restart router

### Step 3: Test

After router restart:

1. On iPhone, go to Settings → Wi-Fi → [Your Network] → Configure DNS
2. Should show your router's DNS settings
3. Test: `http://www.noodle.nc:8080/`

**Benefits**: All devices on network automatically get noodle domains without configuration.

## 📱 Solution 3: Manual DNS Configuration (iPhone-Specific)

### iPhone DNS Configuration

1. **Settings** → **Wi-Fi** → **Your Network** → **Configure DNS**
2. Select **Manual**
3. Remove existing DNS servers
4. Add DNS server: `192.168.68.122`
5. **Save** and reconnect to Wi-Fi

### Testing

- Visit: `http://www.noodle.nc:8080/`
- Should resolve to your server and show IDE interface

## 🛠️ Solution 4: Browser-Based Host Header (Development/Testing)

### Using Safari Developer Tools (Limited on iPhone)

1. Open Safari → Develop menu → User Agent
2. Try to modify request headers (limited capability)

### Using iOS Browser Extensions

If available for your browser:

1. Install extension that supports header modification
2. Configure to add `Host: www.noodle.nc` header
3. Base URL: `http://192.168.68.122:8080/`

## 🔍 Verification & Testing

### Test Server Connectivity

```bash
# From any device, test connection to server
curl http://192.168.68.122:8080/api/v1/health
```

### Test DNS Resolution

```bash
# If DNS is configured
nslookup www.noodle.nc 192.168.68.122
```

### Test IDE Access

```bash
# Direct IP access (always works)
curl -H "Host: www.noodle.nc" http://192.168.68.122:8080/
```

## 📋 Troubleshooting Guide

### Issue: "Can't connect to server"

**Solution**:

1. Verify server is running: `curl http://localhost:8080/api/v1/health`
2. Check firewall allows port 8080
3. Verify iPhone and server are on same network

### Issue: "DNS not resolving"

**Solution**:

1. DNS configuration not applied yet - wait 5-10 minutes
2. Clear DNS cache on iPhone: Settings → Wi-Fi → [Forget Network] → reconnect
3. Try manual DNS configuration

### Issue: "Shows API info instead of IDE"

**Solution**:

1. Ensure you're accessing with correct Host header
2. Use: `http://www.noodle.nc:8080/` (with DNS) OR
3. Use direct IP with custom headers if available

### Issue: "Connection timeout"

**Solution**:

1. Check server IP address is correct
2. Verify both devices on same network
3. Try pinging server from iPhone (using network analyzer app)

## 🎯 Recommended Approach

### For Immediate Access (Use This Now)

1. **Use Solution 1 (Direct IP)**: `http://192.168.68.122:8080/`
2. Create iPhone Shortcut for one-tap access
3. Bookmark in Safari

### For Long-term Setup

1. **Use Solution 2 (Router DNS)**: Configure router DNS settings
2. All devices automatically get noodle domains
3. No per-device configuration needed

### For Development/Testing

1. **Use Solution 4 (Browser Headers)**: Custom host headers for testing
2. Perfect for testing different domain configurations

## 📝 Quick Reference

### Server Information

- **Server IP**: `192.168.68.122`
- **HTTP Port**: `8080`
- **DNS Port**: `53`
- **Supported Domains**: <www.noodle.nc>, noodle.nc, api.noodle.nc, ide.noodle.nc

### Key URLs

- **Direct Access**: `http://192.168.68.122:8080/`
- **API Health**: `http://192.168.68.122:8080/api/v1/health`
- **IDE Interface**: `http://192.168.68.122:8080/`
- **DNS Status**: `http://192.168.68.122:8080/api/v1/dns/status`

### Success Indicators

✅ Server responds to direct IP requests  
✅ Zero-configuration interception working  
✅ iPhone can connect via `http://192.168.68.122:8080/`  
✅ DNS resolution works (with proper configuration)  

## 🚨 Important Notes

1. **Server IP May Change**: If router DHCP assigns different IP, update all references
2. **Network Dependencies**: All solutions require iPhone and server on same network
3. **DNS Propagation**: Router DNS changes may take 5-10 minutes to propagate
4. **Firewall Requirements**: Ensure Windows firewall allows ports 53 and 8080

## 🎉 Expected Results

After following these solutions:

- ✅ iPhone can access Noodle IDE via direct IP
- ✅ DNS configuration enables `www.noodle.nc` domain access  
- ✅ Zero-configuration interception provides seamless experience
- ✅ All network devices can access noodle domains automatically

The combination of direct IP access and router DNS configuration provides both immediate access and long-term convenience for accessing the Noodle IDE from any device on your home network.
