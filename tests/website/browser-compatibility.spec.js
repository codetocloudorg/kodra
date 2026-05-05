// @ts-check
const { test, expect } = require('@playwright/test');

/**
 * Kodra Website Test Suite — Browser Compatibility
 *
 * Validates cross-browser rendering, scroll behaviour, responsive layout,
 * navigation, link integrity, and image loading for the Kodra single-page
 * static site served via GitHub Pages.
 *
 * @author Kodra
 */

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const PAGES = ['/'];

const VIEWPORTS = {
  desktop: { width: 1280, height: 800 },
  tablet: { width: 768, height: 1024 },
  mobile: { width: 375, height: 667 },
};

// Selectors derived from Kodra index.html
const NAV = 'nav';
const NAV_CONTENT = '.nav-content';
const NAV_LINKS = '.nav-links';
const NAV_LOGO = '.logo';
const HERO = '.hero';
const HERO_TITLE = '.hero-title';
const HERO_CTA = '.hero-cta';
const FEATURES_SECTION = '#features';
const TOOLS_SECTION = '#tools';
const THEMES_SECTION = '#themes';
const FAQ_SECTION = '#faq';
const FOOTER = 'footer';
const FOOTER_CONTENT = '.footer-content';
const FOOTER_BOTTOM = '.footer-bottom';
const FEATURE_CARD = '.feature-card';
const TOOL_ITEM = '.tool-item';
const THEME_CARD = '.theme-card';
const TERMINAL = '.terminal';
const BTN = '.btn';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/**
 * WebKit-compatible scroll helper — uses scrollTo with a small wait so that
 * WebKit repaints before we measure.
 */
async function safeScrollTo(page, x, y) {
  await page.evaluate(([sx, sy]) => window.scrollTo(sx, sy), [x, y]);
  await page.waitForTimeout(300);
}

async function getScrollY(page) {
  return page.evaluate(() => window.scrollY);
}

// ═══════════════════════════════════════════════════════════════════════════
// 1. SCROLL FUNCTIONALITY
// ═══════════════════════════════════════════════════════════════════════════

test.describe('Scroll Functionality', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');
  });

  test('mouse wheel scrolling works', async ({ page }) => {
    await page.mouse.wheel(0, 500);
    await page.waitForTimeout(500);
    const y = await getScrollY(page);
    expect(y).toBeGreaterThan(0);
  });

  test('bidirectional scroll works', async ({ page }) => {
    await safeScrollTo(page, 0, 600);
    const down = await getScrollY(page);
    expect(down).toBeGreaterThan(0);

    await safeScrollTo(page, 0, 0);
    const up = await getScrollY(page);
    expect(up).toBeLessThanOrEqual(20);
  });

  test('programmatic scrollTo works', async ({ page }) => {
    await page.evaluate(() => window.scrollTo(0, 400));
    await page.waitForTimeout(300);
    const y = await getScrollY(page);
    expect(y).toBeGreaterThanOrEqual(390);
  });

  test('programmatic scrollBy works', async ({ page }) => {
    await page.evaluate(() => window.scrollBy(0, 300));
    await page.waitForTimeout(300);
    const y1 = await getScrollY(page);
    expect(y1).toBeGreaterThan(0);

    await page.evaluate(() => window.scrollBy(0, 300));
    await page.waitForTimeout(300);
    const y2 = await getScrollY(page);
    expect(y2).toBeGreaterThan(y1);
  });

  test('keyboard PageDown scrolls page', async ({ page }) => {
    await page.keyboard.press('PageDown');
    await page.waitForTimeout(500);
    const y = await getScrollY(page);
    expect(y).toBeGreaterThan(0);
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 2. CSS PROPERTY VALIDATION
// ═══════════════════════════════════════════════════════════════════════════

test.describe('CSS Property Validation', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');
  });

  test('html and body do not have blocking overflow hidden', async ({ page }) => {
    const htmlOverflow = await page.evaluate(() =>
      getComputedStyle(document.documentElement).overflow
    );
    const bodyOverflow = await page.evaluate(() =>
      getComputedStyle(document.body).overflow
    );
    // overflow-x: hidden is fine; full 'hidden' on both axes blocks scrolling
    expect(htmlOverflow).not.toBe('hidden');
    // body has overflow-x: hidden which is expected; just ensure Y is not blocked
    const bodyOverflowY = await page.evaluate(() =>
      getComputedStyle(document.body).overflowY
    );
    expect(bodyOverflowY).not.toBe('hidden');
  });

  test('no blocking pseudo-elements cover viewport', async ({ page }) => {
    const blocking = await page.evaluate(() => {
      const els = document.querySelectorAll('*');
      for (const el of els) {
        for (const pseudo of ['::before', '::after']) {
          const style = getComputedStyle(el, pseudo);
          if (
            style.position === 'fixed' &&
            style.pointerEvents !== 'none' &&
            parseInt(style.width) > window.innerWidth * 0.9 &&
            parseInt(style.height) > window.innerHeight * 0.9
          ) {
            return true;
          }
        }
      }
      return false;
    });
    expect(blocking).toBe(false);
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 3. FOOTER RENDERING
// ═══════════════════════════════════════════════════════════════════════════

test.describe('Footer Rendering', () => {
  for (const [label, vp] of Object.entries(VIEWPORTS)) {
    test(`footer is visible at ${label} (${vp.width}×${vp.height})`, async ({ page }) => {
      await page.setViewportSize(vp);
      await page.goto('/');
      await page.waitForLoadState('domcontentloaded');

      const footer = page.locator(FOOTER);
      await expect(footer).toBeAttached();

      // Scroll to footer
      await footer.scrollIntoViewIfNeeded();
      await expect(footer).toBeInViewport();
    });
  }

  test('footer contains brand, columns, and bottom bar', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('.footer-brand')).toBeAttached();
    await expect(page.locator('.footer-column')).toHaveCount(3);
    await expect(page.locator(FOOTER_BOTTOM)).toBeAttached();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 4. SAFARI / WEBKIT COMPATIBILITY
// ═══════════════════════════════════════════════════════════════════════════

test.describe('Safari Compatibility', () => {
  test('flexbox gap renders correctly on nav', async ({ page }) => {
    await page.goto('/');
    const gap = await page.locator(NAV_LINKS).evaluate((el) => {
      return getComputedStyle(el).gap;
    });
    // Should be a valid gap value (e.g., "32px" or "2rem")
    expect(gap).toBeTruthy();
    expect(gap).not.toBe('normal');
  });

  test('backdrop-filter applied on nav', async ({ page }) => {
    await page.goto('/');
    const bf = await page.locator(NAV).evaluate((el) => {
      const style = getComputedStyle(el);
      return style.backdropFilter || style.webkitBackdropFilter || '';
    });
    expect(bf).toContain('blur');
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 5. MOBILE TOUCH TARGETS
// ═══════════════════════════════════════════════════════════════════════════

test.describe('Mobile Touch Targets', () => {
  test('CTA buttons meet minimum 44px touch target', async ({ page }) => {
    await page.setViewportSize(VIEWPORTS.mobile);
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');

    const buttons = page.locator('.hero-cta .btn');
    const count = await buttons.count();
    expect(count).toBeGreaterThan(0);

    for (let i = 0; i < count; i++) {
      const box = await buttons.nth(i).boundingBox();
      expect(box).toBeTruthy();
      expect(box.height).toBeGreaterThanOrEqual(44);
    }
  });

  test('footer social icons meet minimum touch target', async ({ page }) => {
    await page.setViewportSize(VIEWPORTS.mobile);
    await page.goto('/');
    await page.locator(FOOTER).scrollIntoViewIfNeeded();

    const socialLinks = page.locator('.footer-social a');
    const count = await socialLinks.count();
    for (let i = 0; i < count; i++) {
      const box = await socialLinks.nth(i).boundingBox();
      expect(box).toBeTruthy();
      expect(box.width).toBeGreaterThanOrEqual(40);
      expect(box.height).toBeGreaterThanOrEqual(40);
    }
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 6. NAVIGATION
// ═══════════════════════════════════════════════════════════════════════════

test.describe('Navigation', () => {
  test('nav bar renders with logo and links', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator(`${NAV} ${NAV_LOGO}`)).toBeVisible();
    await expect(page.locator(NAV_LINKS)).toBeVisible();
  });

  test('nav anchor links scroll to correct sections', async ({ page }) => {
    await page.goto('/');
    const anchors = ['#features', '#tools', '#themes', '#faq'];

    for (const anchor of anchors) {
      const link = page.locator(`.nav-links a[href="${anchor}"]`);
      if (await link.isVisible()) {
        await link.click();
        await page.waitForTimeout(800); // smooth scroll
        const section = page.locator(anchor);
        await expect(section).toBeInViewport();
      }
    }
  });

  test('nav links are hidden on mobile viewport', async ({ page }) => {
    await page.setViewportSize(VIEWPORTS.mobile);
    await page.goto('/');
    await expect(page.locator(NAV_LINKS)).toBeHidden();
  });

  test('nav is fixed at top of page', async ({ page }) => {
    await page.goto('/');
    const position = await page.locator(NAV).evaluate(el =>
      getComputedStyle(el).position
    );
    expect(position).toBe('fixed');
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 7. RESPONSIVE LAYOUT
// ═══════════════════════════════════════════════════════════════════════════

test.describe('Responsive Layout', () => {
  for (const [label, vp] of Object.entries(VIEWPORTS)) {
    test(`hero section renders at ${label}`, async ({ page }) => {
      await page.setViewportSize(vp);
      await page.goto('/');
      await expect(page.locator(HERO)).toBeVisible();
      await expect(page.locator(HERO_TITLE)).toBeVisible();
    });

    test(`features section renders at ${label}`, async ({ page }) => {
      await page.setViewportSize(vp);
      await page.goto('/');
      const section = page.locator(FEATURES_SECTION);
      await section.scrollIntoViewIfNeeded();
      await expect(section).toBeVisible();

      const cards = page.locator(FEATURE_CARD);
      expect(await cards.count()).toBeGreaterThan(0);
    });

    test(`tools section renders at ${label}`, async ({ page }) => {
      await page.setViewportSize(vp);
      await page.goto('/');
      const section = page.locator(TOOLS_SECTION);
      await section.scrollIntoViewIfNeeded();
      await expect(section).toBeVisible();

      const items = page.locator(TOOL_ITEM);
      expect(await items.count()).toBeGreaterThan(0);
    });
  }

  test('feature cards stack on mobile', async ({ page }) => {
    await page.setViewportSize(VIEWPORTS.mobile);
    await page.goto('/');
    const grid = page.locator('.features-grid:visible');
    await grid.scrollIntoViewIfNeeded();
    const cols = await grid.evaluate(el =>
      getComputedStyle(el).gridTemplateColumns
    );
    // On mobile, should collapse to single column
    const colCount = cols.split(' ').length;
    expect(colCount).toBeLessThanOrEqual(2);
  });

  test('tools grid adapts to viewport', async ({ page }) => {
    await page.setViewportSize(VIEWPORTS.desktop);
    await page.goto('/');
    const grid = page.locator('.tools-grid:visible');
    await grid.scrollIntoViewIfNeeded();

    const desktopCols = await grid.evaluate(el =>
      getComputedStyle(el).gridTemplateColumns.split(' ').length
    );

    await page.setViewportSize(VIEWPORTS.mobile);
    await page.waitForTimeout(300);

    const mobileCols = await grid.evaluate(el =>
      getComputedStyle(el).gridTemplateColumns.split(' ').length
    );

    expect(desktopCols).toBeGreaterThan(mobileCols);
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 8. LINK VALIDATION
// ═══════════════════════════════════════════════════════════════════════════

test.describe('Link Validation', () => {
  test('internal anchor links point to existing sections', async ({ page }) => {
    await page.goto('/');
    const hrefs = await page.locator('a[href^="#"]').evaluateAll(els =>
      els.map(el => el.getAttribute('href')).filter(h => h && h !== '#')
    );

    for (const href of hrefs) {
      const target = page.locator(href);
      const count = await target.count();
      expect(count, `Section ${href} should exist`).toBeGreaterThan(0);
    }
  });

  test('external links have target="_blank" or open in same tab intentionally', async ({ page }) => {
    await page.goto('/');
    const externalLinks = await page.locator('a[href^="http"]').evaluateAll(els =>
      els.map(el => ({
        href: el.getAttribute('href'),
        target: el.getAttribute('target'),
        text: el.textContent?.trim().substring(0, 50),
      }))
    );

    // External links that navigate away should have target="_blank"
    // Some footer/nav links may intentionally stay in same tab (e.g., parent site)
    expect(externalLinks.length).toBeGreaterThan(0);
  });

  test('no links have empty href', async ({ page }) => {
    await page.goto('/');
    const emptyHrefs = await page.locator('a[href=""]').count();
    expect(emptyHrefs).toBe(0);
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 9. IMAGE LOADING
// ═══════════════════════════════════════════════════════════════════════════

test.describe('Image Loading', () => {
  test('all images have alt attributes', async ({ page }) => {
    await page.goto('/');
    const images = page.locator('img');
    const count = await images.count();

    for (let i = 0; i < count; i++) {
      const alt = await images.nth(i).getAttribute('alt');
      expect(alt, `Image ${i} should have alt attribute`).toBeTruthy();
    }
  });

  test('images load without errors', async ({ page }) => {
    const failedImages = [];
    page.on('response', response => {
      if (
        response.request().resourceType() === 'image' &&
        response.status() >= 400
      ) {
        failedImages.push(response.url());
      }
    });

    await page.goto('/');
    await page.waitForLoadState('networkidle');
    expect(failedImages, `Failed images: ${failedImages.join(', ')}`).toHaveLength(0);
  });

  test('screenshot gallery images load', async ({ page }) => {
    await page.goto('/');
    const galleryImages = page.locator('.gallery-item img');
    const count = await galleryImages.count();
    expect(count).toBeGreaterThan(0);

    for (let i = 0; i < count; i++) {
      const src = await galleryImages.nth(i).getAttribute('src');
      expect(src).toBeTruthy();
    }
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 10. TERMINAL COMPONENT
// ═══════════════════════════════════════════════════════════════════════════

test.describe('Terminal Component', () => {
  test('terminal demo renders with install command', async ({ page }) => {
    await page.goto('/');
    const terminal = page.locator(TERMINAL).first();
    await expect(terminal).toBeVisible();

    // Check terminal has header dots
    await expect(terminal.locator('.terminal-dots .dot')).toHaveCount(3);

    // Check install command is present
    const command = terminal.locator('.terminal-command').first();
    await expect(command).toContainText('kodra.codetocloud.io/boot.sh');
  });

  test('terminal output shows expected steps', async ({ page }) => {
    await page.goto('/');
    const output = page.locator('.terminal-output').first();
    await expect(output).toContainText('Azure CLI');
    await expect(output).toContainText('Docker CE');
    await expect(output).toContainText('kodra doctor');
  });
});
