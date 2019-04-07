# Introductions
<p>Have you ever suffered from suffering internet slowly? DNS cache pollution? hijack from your internet service provider? DNS requirements redirected by Great Fire Wall? Maybe SmartDNS can help you escape this, it can help you inquire the fastest DNS server via TCP not UDP and I pre-setted a ban list of black hole routings which counterfeited by Great Fire Wall especially on your VPS.</p>
<br />

# In which situations are applicable?
<p>Any situations that you don't want to be a DNS requirement victim and speed up query domain name.</p>
<br />
<p>For example to me: I have a v2ray tunnel proxy across my VPS which located in HongKong area and it managed by Aliyun/AlibabaCloud, but recently I found logs from v2ray's client and it showed a lot of DNS request from IP address 31.13.6.16, 172.217.24.46, 31.13.69.129, 172.217.24.193, 8.7.198.45 and returned no results. I searched these IP and found they are really from the Great Fire Wall: https://zh.wikipedia.org/wiki/域名服务器缓存污染  so I have to use SmartDNS to provent from this situation.</p>

# Why to code this script?
<p>Although original project is here: https://github.com/pymumu/smartdns and it's developer had given the methods to install it, but I still found a lot of obstructions during installation, so I make a script to reduce variety trivial process, enjoy it!</p>
<br />

# Install
<p>Currently, the script is only support Debian/Ubuntu, doesn't support neither Windows/CentOS/MacOS etc... You can execute the following:</p>
