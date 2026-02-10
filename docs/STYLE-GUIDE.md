# Code To Cloud Project Style Guide

This guide documents the GitHub-inspired dark theme style used in Kodra. Copy these templates to give your project the same professional look.

## Quick Setup Checklist

```bash
# 1. Create these files in your repo root:
touch CNAME robots.txt sitemap.xml index.html README.md

# 2. Enable GitHub Pages:
# Settings → Pages → Source: Deploy from branch → main → / (root)

# 3. Configure custom domain (optional):
# Add CNAME record in your DNS pointing to <username>.github.io
```

---

## 1. CNAME (Custom Domain)

Create `CNAME` with your subdomain:

```
yourproject.codetocloud.io
```

**DNS Setup (Cloudflare/Route53):**
| Type | Name | Target |
|------|------|--------|
| CNAME | yourproject | codetocloudorg.github.io |

---

## 2. robots.txt (SEO)

```txt
User-agent: *
Allow: /

Sitemap: https://yourproject.codetocloud.io/sitemap.xml
```

---

## 3. sitemap.xml (Google Indexing)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://yourproject.codetocloud.io/</loc>
    <lastmod>2026-02-09</lastmod>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
  <url>
    <loc>https://yourproject.codetocloud.io/docs/</loc>
    <lastmod>2026-02-09</lastmod>
    <changefreq>monthly</changefreq>
    <priority>0.8</priority>
  </url>
</urlset>
```

**Submit to Google:**
1. Go to [Google Search Console](https://search.google.com/search-console)
2. Add property → URL prefix → `https://yourproject.codetocloud.io`
3. Verify via DNS TXT record or HTML file
4. Submit sitemap URL

---

## 4. README.md Template

````markdown
<div align="center">

```
 █████╗ ███████╗ ██████╗██╗██╗
██╔══██╗██╔════╝██╔════╝██║██║
███████║███████╗██║     ██║██║
██╔══██║╚════██║██║     ██║██║
██║  ██║███████║╚██████╗██║██║
╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝╚═╝
```

**Your tagline here—short and memorable.**

[![Version](https://img.shields.io/badge/version-0.1.0-blue?style=flat-square)](VERSION)
[![CI](https://img.shields.io/github/actions/workflow/status/codetocloudorg/yourproject/ci.yml?branch=main&style=flat-square&label=CI)](https://github.com/codetocloudorg/yourproject/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Discord](https://img.shields.io/badge/Discord-Join-5865F2?style=flat-square&logo=discord&logoColor=white)](https://discord.gg/vwfwq2EpXJ)

*Developed by [Code To Cloud](https://www.codetocloud.io)*

</div>

---

**The pitch.** One paragraph explaining what this does and why it matters.

## Quick Start

```bash
# One-liner install
curl -fsSL https://yourproject.codetocloud.io/install.sh | bash
```

## Features

| Feature | Description |
|---------|-------------|
| **Feature 1** | What it does |
| **Feature 2** | What it does |

## Documentation

- [Installation Guide](docs/INSTALL.md)
- [Configuration](docs/CONFIG.md)
- [Contributing](CONTRIBUTING.md)

## License

MIT License - see [LICENSE](LICENSE)

---

<div align="center">

[![Discord](https://img.shields.io/badge/Discord-Join_Us-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/vwfwq2EpXJ)
[![GitHub](https://img.shields.io/badge/GitHub-codetocloudorg-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/codetocloudorg)

**[yourproject.codetocloud.io](https://yourproject.codetocloud.io)**

*Developed by [Code To Cloud](https://www.codetocloud.io)*

</div>
````

### ASCII Art Generator

Use this site: https://patorjk.com/software/taag/
- Font: **ANSI Shadow** (matches Kodra style)
- Character Width: Default
- Character Height: Default

---

## 5. index.html Template

Save as `index.html` in repo root:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="YOUR_DESCRIPTION - one sentence.">
    <meta name="theme-color" content="#0d1117">
    <title>YOUR_PROJECT - Your Tagline</title>
    
    <!-- Open Graph -->
    <meta property="og:type" content="website">
    <meta property="og:url" content="https://yourproject.codetocloud.io/">
    <meta property="og:title" content="YOUR_PROJECT - Your Tagline">
    <meta property="og:description" content="YOUR_DESCRIPTION">
    <meta property="og:site_name" content="YOUR_PROJECT">
    
    <!-- Twitter -->
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="YOUR_PROJECT - Your Tagline">
    <meta name="twitter:description" content="YOUR_DESCRIPTION">
    
    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    
    <style>
        /* ============================================
           CODE TO CLOUD - GITHUB DARK THEME
           Copy this entire <style> block
           ============================================ */
        
        :root {
            /* GitHub Dark Colors */
            --bg-primary: #0d1117;
            --bg-secondary: #161b22;
            --bg-tertiary: #21262d;
            --border-default: #30363d;
            --border-muted: #21262d;
            
            /* Text */
            --text-primary: #e6edf3;
            --text-secondary: #8b949e;
            --text-muted: #6e7681;
            
            /* Accent Colors */
            --accent-blue: #58a6ff;
            --accent-green: #3fb950;
            --accent-purple: #a371f7;
            --accent-cyan: #79c0ff;
            --accent-orange: #d29922;
            --accent-red: #f85149;
            
            /* Gradients */
            --gradient-blue: linear-gradient(135deg, #58a6ff 0%, #a371f7 100%);
            --gradient-glow: radial-gradient(ellipse at center, rgba(88, 166, 255, 0.15) 0%, transparent 70%);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html { scroll-behavior: smooth; }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: var(--bg-primary);
            color: var(--text-primary);
            line-height: 1.6;
            overflow-x: hidden;
        }

        /* Navigation */
        nav {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 100;
            background: rgba(13, 17, 23, 0.8);
            backdrop-filter: blur(10px);
            border-bottom: 1px solid var(--border-muted);
            padding: 1rem 2rem;
        }

        .nav-content {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .logo {
            font-family: 'JetBrains Mono', monospace;
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--text-primary);
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .logo-icon {
            width: 32px;
            height: 32px;
            background: var(--gradient-blue);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1rem;
        }

        .nav-links {
            display: flex;
            gap: 2rem;
            align-items: center;
        }

        .nav-links a {
            color: var(--text-secondary);
            text-decoration: none;
            font-size: 0.9rem;
            font-weight: 500;
            transition: color 0.2s;
        }

        .nav-links a:hover { color: var(--text-primary); }

        .nav-btn {
            background: var(--bg-tertiary);
            border: 1px solid var(--border-default);
            padding: 0.5rem 1rem;
            border-radius: 6px;
            color: var(--text-primary) !important;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .nav-btn:hover { background: var(--border-default); }

        /* Hero Section */
        .hero {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 8rem 2rem 4rem;
            position: relative;
            text-align: center;
        }

        .hero::before {
            content: '';
            position: absolute;
            top: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 150%;
            height: 100%;
            background: var(--gradient-glow);
            pointer-events: none;
        }

        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            background: var(--bg-secondary);
            border: 1px solid var(--border-default);
            padding: 0.5rem 1rem;
            border-radius: 50px;
            font-size: 0.85rem;
            color: var(--text-secondary);
            margin-bottom: 2rem;
        }

        .hero-badge-dot {
            width: 8px;
            height: 8px;
            background: var(--accent-green);
            border-radius: 50%;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }

        .ascii-art {
            font-family: 'JetBrains Mono', monospace;
            font-size: clamp(0.5rem, 2vw, 1rem);
            line-height: 1.2;
            margin-bottom: 1.5rem;
            background: var(--gradient-blue);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .hero-title {
            font-size: clamp(3rem, 8vw, 5rem);
            font-weight: 800;
            line-height: 1.1;
            margin-bottom: 1.5rem;
            letter-spacing: -0.02em;
        }

        .hero-title .gradient {
            background: var(--gradient-blue);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .hero-subtitle {
            font-size: 1.25rem;
            color: var(--text-secondary);
            max-width: 600px;
            margin-bottom: 3rem;
        }

        /* Buttons */
        .btn {
            padding: 0.875rem 1.5rem;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            transition: all 0.2s;
            cursor: pointer;
            border: none;
        }

        .btn-primary {
            background: var(--accent-blue);
            color: var(--bg-primary);
        }

        .btn-primary:hover {
            background: #79c0ff;
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(88, 166, 255, 0.3);
        }

        .btn-secondary {
            background: var(--bg-tertiary);
            border: 1px solid var(--border-default);
            color: var(--text-primary);
        }

        .btn-secondary:hover {
            background: var(--border-default);
            transform: translateY(-2px);
        }

        /* Terminal Component */
        .terminal {
            background: var(--bg-secondary);
            border: 1px solid var(--border-default);
            border-radius: 12px;
            width: 100%;
            max-width: 700px;
            overflow: hidden;
            box-shadow: 0 16px 48px rgba(0, 0, 0, 0.4);
            text-align: left;
        }

        .terminal-header {
            background: var(--bg-tertiary);
            padding: 0.75rem 1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            border-bottom: 1px solid var(--border-muted);
        }

        .terminal-dot {
            width: 12px;
            height: 12px;
            border-radius: 50%;
        }

        .terminal-dot.red { background: #f85149; }
        .terminal-dot.yellow { background: #d29922; }
        .terminal-dot.green { background: #3fb950; }

        .terminal-title {
            flex: 1;
            text-align: center;
            color: var(--text-muted);
            font-size: 0.8rem;
            font-family: 'JetBrains Mono', monospace;
        }

        .terminal-body {
            padding: 1.5rem;
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.9rem;
            line-height: 1.8;
        }

        .terminal-prompt { color: var(--accent-green); }
        .terminal-command { color: var(--text-primary); }
        .terminal-output { color: var(--text-secondary); margin-top: 0.5rem; }

        /* Section Styling */
        section {
            padding: 6rem 2rem;
            max-width: 1200px;
            margin: 0 auto;
        }

        .section-header { text-align: center; margin-bottom: 4rem; }

        .section-label {
            display: inline-block;
            color: var(--accent-blue);
            font-size: 0.85rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.1em;
            margin-bottom: 1rem;
        }

        .section-title {
            font-size: clamp(2rem, 5vw, 3rem);
            font-weight: 700;
            margin-bottom: 1rem;
        }

        .section-subtitle {
            color: var(--text-secondary);
            font-size: 1.125rem;
            max-width: 600px;
            margin: 0 auto;
        }

        /* Feature Cards */
        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
        }

        .feature-card {
            background: var(--bg-secondary);
            border: 1px solid var(--border-default);
            border-radius: 12px;
            padding: 1.5rem;
            transition: all 0.3s;
        }

        .feature-card:hover {
            border-color: var(--accent-blue);
            transform: translateY(-4px);
            box-shadow: 0 12px 24px rgba(0, 0, 0, 0.3);
        }

        .feature-icon {
            width: 48px;
            height: 48px;
            background: var(--bg-tertiary);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 1rem;
            font-size: 1.5rem;
        }

        .feature-title {
            font-size: 1.125rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .feature-description {
            color: var(--text-secondary);
            font-size: 0.9rem;
        }

        /* Footer */
        footer {
            background: var(--bg-secondary);
            border-top: 1px solid var(--border-default);
            padding: 4rem 2rem;
            margin-top: 4rem;
        }

        .footer-content {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1fr;
            gap: 3rem;
        }

        @media (max-width: 768px) {
            .footer-content { grid-template-columns: 1fr; }
            .nav-links { display: none; }
        }

        .footer-brand p {
            color: var(--text-secondary);
            font-size: 0.9rem;
            margin: 1rem 0;
        }

        .footer-social {
            display: flex;
            gap: 1rem;
        }

        .footer-social a {
            width: 40px;
            height: 40px;
            background: var(--bg-tertiary);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--text-secondary);
            transition: all 0.2s;
        }

        .footer-social a:hover {
            background: var(--accent-blue);
            color: var(--bg-primary);
        }

        .footer-column h4 {
            font-size: 0.85rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.1em;
            color: var(--text-secondary);
            margin-bottom: 1rem;
        }

        .footer-column ul { list-style: none; }
        .footer-column li { margin-bottom: 0.5rem; }

        .footer-column a {
            color: var(--text-secondary);
            text-decoration: none;
            font-size: 0.9rem;
            transition: color 0.2s;
        }

        .footer-column a:hover { color: var(--text-primary); }

        .footer-bottom {
            max-width: 1200px;
            margin: 3rem auto 0;
            padding-top: 2rem;
            border-top: 1px solid var(--border-default);
            text-align: center;
            color: var(--text-muted);
            font-size: 0.85rem;
        }

        .footer-bottom a {
            color: var(--accent-blue);
            text-decoration: none;
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav>
        <div class="nav-content">
            <a href="#" class="logo">
                <div class="logo-icon">Y</div>
                YourProject
            </a>
            <div class="nav-links">
                <a href="#features">Features</a>
                <a href="#docs">Docs</a>
                <a href="https://discord.gg/vwfwq2EpXJ" class="nav-btn" style="background: #5865F2; border-color: #5865F2;">
                    <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                        <path d="M13.545 2.907a13.227 13.227 0 0 0-3.257-1.011.05.05 0 0 0-.052.025c-.141.25-.297.577-.406.833a12.19 12.19 0 0 0-3.658 0 8.258 8.258 0 0 0-.412-.833.051.051 0 0 0-.052-.025c-1.125.194-2.22.534-3.257 1.011a.041.041 0 0 0-.021.018C.356 6.024-.213 9.047.066 12.032c.001.014.01.028.021.037a13.276 13.276 0 0 0 3.995 2.02.05.05 0 0 0 .056-.019c.308-.42.582-.863.818-1.329a.05.05 0 0 0-.01-.059.051.051 0 0 0-.018-.011 8.875 8.875 0 0 1-1.248-.595.05.05 0 0 1-.02-.066.051.051 0 0 1 .015-.019c.084-.063.168-.129.248-.195a.05.05 0 0 1 .051-.007c2.619 1.196 5.454 1.196 8.041 0a.052.052 0 0 1 .053.007c.08.066.164.132.248.195a.051.051 0 0 1-.004.085 8.254 8.254 0 0 1-1.249.594.05.05 0 0 0-.03.03.052.052 0 0 0 .003.041c.24.465.515.909.817 1.329a.05.05 0 0 0 .056.019 13.235 13.235 0 0 0 4.001-2.02.049.049 0 0 0 .021-.037c.334-3.451-.559-6.449-2.366-9.106a.034.034 0 0 0-.02-.019Z"/>
                    </svg>
                    Discord
                </a>
                <a href="https://github.com/codetocloudorg/yourproject" class="nav-btn">
                    <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                        <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"/>
                    </svg>
                    GitHub
                </a>
            </div>
        </div>
    </nav>

    <!-- Hero -->
    <section class="hero">
        <div class="hero-badge">
            <span class="hero-badge-dot"></span>
            v0.1.0 — Just launched
        </div>
        
        <pre class="ascii-art">
██╗   ██╗ ██████╗ ██╗   ██╗██████╗ 
╚██╗ ██╔╝██╔═══██╗██║   ██║██╔══██╗
 ╚████╔╝ ██║   ██║██║   ██║██████╔╝
  ╚██╔╝  ██║   ██║██║   ██║██╔══██╗
   ██║   ╚██████╔╝╚██████╔╝██║  ██║
   ╚═╝    ╚═════╝  ╚═════╝ ╚═╝  ╚═╝
        </pre>
        
        <h1 class="hero-title">
            Your Main<br>
            <span class="gradient">Headline</span>
        </h1>
        
        <p class="hero-subtitle">
            Your description goes here. Keep it under two sentences.
        </p>
        
        <div style="display: flex; gap: 1rem; flex-wrap: wrap; justify-content: center; margin-bottom: 4rem;">
            <a href="#install" class="btn btn-primary">Get Started</a>
            <a href="https://github.com/codetocloudorg/yourproject" class="btn btn-secondary">View on GitHub</a>
        </div>
        
        <!-- Terminal Demo -->
        <div class="terminal" id="install">
            <div class="terminal-header">
                <span class="terminal-dot red"></span>
                <span class="terminal-dot yellow"></span>
                <span class="terminal-dot green"></span>
                <span class="terminal-title">bash</span>
            </div>
            <div class="terminal-body">
                <div>
                    <span class="terminal-prompt">$</span>
                    <span class="terminal-command">curl -fsSL https://yourproject.codetocloud.io/install.sh | bash</span>
                </div>
                <div class="terminal-output">
                    ✓ Installed successfully<br>
                    <span style="color: var(--accent-green);">Done!</span>
                </div>
            </div>
        </div>
    </section>

    <!-- Features -->
    <section id="features">
        <div class="section-header">
            <span class="section-label">Features</span>
            <h2 class="section-title">What you get</h2>
            <p class="section-subtitle">Brief description of the features section.</p>
        </div>
        
        <div class="features-grid">
            <div class="feature-card">
                <div class="feature-icon">⚡</div>
                <h3 class="feature-title">Feature One</h3>
                <p class="feature-description">Description of this feature and why it matters.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">🔒</div>
                <h3 class="feature-title">Feature Two</h3>
                <p class="feature-description">Description of this feature and why it matters.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">🚀</div>
                <h3 class="feature-title">Feature Three</h3>
                <p class="feature-description">Description of this feature and why it matters.</p>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer>
        <div class="footer-content">
            <div class="footer-brand">
                <a href="#" class="logo">
                    <div class="logo-icon">Y</div>
                    YourProject
                </a>
                <p>Your tagline here.</p>
                <div class="footer-social">
                    <a href="https://github.com/codetocloudorg/yourproject" aria-label="GitHub">
                        <svg width="20" height="20" viewBox="0 0 16 16" fill="currentColor">
                            <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"/>
                        </svg>
                    </a>
                    <a href="https://discord.gg/vwfwq2EpXJ" aria-label="Discord">
                        <svg width="20" height="20" viewBox="0 0 16 16" fill="currentColor">
                            <path d="M13.545 2.907a13.227 13.227 0 0 0-3.257-1.011.05.05 0 0 0-.052.025c-.141.25-.297.577-.406.833a12.19 12.19 0 0 0-3.658 0 8.258 8.258 0 0 0-.412-.833.051.051 0 0 0-.052-.025c-1.125.194-2.22.534-3.257 1.011a.041.041 0 0 0-.021.018C.356 6.024-.213 9.047.066 12.032c.001.014.01.028.021.037a13.276 13.276 0 0 0 3.995 2.02.05.05 0 0 0 .056-.019c.308-.42.582-.863.818-1.329a.05.05 0 0 0-.01-.059.051.051 0 0 0-.018-.011 8.875 8.875 0 0 1-1.248-.595.05.05 0 0 1-.02-.066.051.051 0 0 1 .015-.019c.084-.063.168-.129.248-.195a.05.05 0 0 1 .051-.007c2.619 1.196 5.454 1.196 8.041 0a.052.052 0 0 1 .053.007c.08.066.164.132.248.195a.051.051 0 0 1-.004.085 8.254 8.254 0 0 1-1.249.594.05.05 0 0 0-.03.03.052.052 0 0 0 .003.041c.24.465.515.909.817 1.329a.05.05 0 0 0 .056.019 13.235 13.235 0 0 0 4.001-2.02.049.049 0 0 0 .021-.037c.334-3.451-.559-6.449-2.366-9.106a.034.034 0 0 0-.02-.019Z"/>
                        </svg>
                    </a>
                </div>
            </div>
            
            <div class="footer-column">
                <h4>Product</h4>
                <ul>
                    <li><a href="#features">Features</a></li>
                    <li><a href="#docs">Documentation</a></li>
                </ul>
            </div>
            
            <div class="footer-column">
                <h4>Resources</h4>
                <ul>
                    <li><a href="https://github.com/codetocloudorg/yourproject">GitHub</a></li>
                    <li><a href="https://github.com/codetocloudorg/yourproject/issues">Report Issue</a></li>
                </ul>
            </div>
            
            <div class="footer-column">
                <h4>Company</h4>
                <ul>
                    <li><a href="https://www.codetocloud.io">Code To Cloud</a></li>
                    <li><a href="https://discord.gg/vwfwq2EpXJ">Discord</a></li>
                </ul>
            </div>
        </div>
        
        <div class="footer-bottom">
            <p>Developed by <a href="https://www.codetocloud.io">Code To Cloud</a>. Released under the MIT License.</p>
        </div>
    </footer>
</body>
</html>
```

---

## 6. Color Reference

| Variable | Hex | Usage |
|----------|-----|-------|
| `--bg-primary` | `#0d1117` | Main background |
| `--bg-secondary` | `#161b22` | Cards, footer |
| `--bg-tertiary` | `#21262d` | Buttons, inputs |
| `--border-default` | `#30363d` | Borders |
| `--text-primary` | `#e6edf3` | Headings |
| `--text-secondary` | `#8b949e` | Body text |
| `--accent-blue` | `#58a6ff` | Links, CTAs |
| `--accent-green` | `#3fb950` | Success |
| `--accent-purple` | `#a371f7` | Gradients |

---

## 7. Google Search Console Setup

1. **Verify ownership:**
   - Add TXT record to DNS: `google-site-verification=YOUR_CODE`
   - Or upload `google*.html` file to repo root

2. **Submit sitemap:**
   - Go to Search Console → Sitemaps
   - Enter: `https://yourproject.codetocloud.io/sitemap.xml`
   - Click Submit

3. **Request indexing:**
   - URL Inspection → Enter your URL
   - Click "Request Indexing"

4. **Monitor:**
   - Check "Coverage" for any issues
   - Takes 1-2 weeks for Google to index

---

## File Checklist

```
your-repo/
├── CNAME                 # Custom domain
├── robots.txt            # SEO allow/disallow
├── sitemap.xml           # Page listing for Google
├── index.html            # Landing page
├── README.md             # GitHub readme
├── LICENSE               # MIT license
├── CONTRIBUTING.md       # Contribution guide (optional)
├── SECURITY.md           # Security policy (optional)
└── docs/
    └── *.md              # Additional docs
```

---

*Style guide based on [Kodra](https://kodra.codetocloud.io) — Developed by [Code To Cloud](https://www.codetocloud.io)*
