---
name: Secure Vault Narrative
colors:
  surface: '#fcf8ff'
  surface-dim: '#dcd9e2'
  surface-bright: '#fcf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f2fb'
  surface-container: '#f0ecf6'
  surface-container-high: '#eae7f0'
  surface-container-highest: '#e4e1ea'
  on-surface: '#1b1b21'
  on-surface-variant: '#464652'
  inverse-surface: '#303037'
  inverse-on-surface: '#f3eff8'
  outline: '#777683'
  outline-variant: '#c7c5d4'
  surface-tint: '#5153b6'
  primary: '#17137f'
  on-primary: '#ffffff'
  primary-container: '#303094'
  on-primary-container: '#9fa1ff'
  inverse-primary: '#c1c1ff'
  secondary: '#755a1a'
  on-secondary: '#ffffff'
  secondary-container: '#fed88b'
  on-secondary-container: '#785d1d'
  tertiary: '#282927'
  on-tertiary: '#ffffff'
  tertiary-container: '#3e3f3c'
  on-tertiary-container: '#aaaaa7'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e1dfff'
  primary-fixed-dim: '#c1c1ff'
  on-primary-fixed: '#08006c'
  on-primary-fixed-variant: '#39399d'
  secondary-fixed: '#ffdf9f'
  secondary-fixed-dim: '#e6c278'
  on-secondary-fixed: '#261a00'
  on-secondary-fixed-variant: '#5b4302'
  tertiary-fixed: '#e3e2df'
  tertiary-fixed-dim: '#c7c7c3'
  on-tertiary-fixed: '#1b1c1a'
  on-tertiary-fixed-variant: '#464744'
  background: '#fcf8ff'
  on-background: '#1b1b21'
  surface-variant: '#e4e1ea'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  title-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-md:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 16px
  margin-mobile: 20px
---

## Brand & Style

The design system establishes a personality of **quiet confidence and warmth**. It balances the clinical security of a private vault with the tactile, approachable nature of a personal notebook. 

The aesthetic is **Corporate Modern with a Geometric twist**, leaning into high-clarity layouts and structured information density. It prioritizes legibility and swift navigation, using color not just for decoration, but as a functional semantic layer to categorize intellectual property. The emotional goal is to make the user feel their data is both impenetrable to others and instantly accessible to them.

## Colors

The palette is anchored by **Sample Indigo**, a deep, authoritative blue that signals security. This is contrasted by **Gold**, which acts as a warm, human-centric accent for primary actions and "Voice" content. 

The background utilizes a **Warm Off-White** to reduce eye strain and move away from the sterility of pure white. Semantic categorization is achieved through a monochromatic Indigo scale for textual and file-based data, while auditory data (Voice) is highlighted with the Gold accent to ensure it stands out in visual lists.

## Typography

This design system uses **Inter** exclusively to leverage its geometric precision and excellent legibility at small scales. 

Headlines utilize tighter letter spacing and heavier weights to feel "locked" and secure. Body text maintains a generous line height for readability in long-form notes. Labels use a slight tracking increase and uppercase styling for auxiliary metadata, creating a clear distinction between content and UI chrome.

## Layout & Spacing

The layout follows a **Fluid Grid** model optimized for mobile-first vaulting. A 4-column grid is used for mobile devices with a 20px outer margin and 16px gutters.

- **Vertical Rhythm:** Built on a 4px baseline. Components are separated by `md` (16px) or `lg` (24px) units to maintain an open, calm feeling.
- **Density:** High density for list views (using 8px internal padding) to allow users to see more "vaulted" items at once, while individual item views use lower density for focus.

## Elevation & Depth

This design system uses **Tonal Layers** rather than aggressive shadows to define hierarchy. 

- **Surface Level:** The warm off-white background is the lowest level.
- **Cards/Items:** Sit on the background with a 1px `neutral.outline` or a very soft, diffused ambient shadow (8% opacity) to provide just enough lift to signify interactability.
- **FAB & Navigation:** Use a higher elevation with a more pronounced shadow to indicate they float above the content stream.
- **Graph View:** Uses z-index layering where nodes are semi-transparent when not in focus, creating a sense of deep, navigable space.

## Shapes

The shape language is a core differentiator, moving between organic and geometric. 

- **Cards:** 16px corners provide a friendly, modern container for files and notes.
- **Buttons:** A slightly tighter 12px radius ensures they feel distinct from content cards.
- **FAB & Icons:** Utilize a **28px Squircle** (superellipse) for a premium, custom feel that breaks the standard circular convention of mobile OS patterns.
- **Tags:** Fully rounded (pill) to maximize contrast with the squarer content blocks.

## Components

### Item Tiles
Rectangular cards with a 16px radius. Each tile features a 4px wide vertical "type strip" on the far left edge, color-coded by the `content_types` tokens (e.g., Indigo for notes, Gold for voice). Titles use `title-lg` and metadata uses `label-md`.

### Squircle FABs
The primary action button is a 56x56px Squircle (28px radius/curvature) in `primary_color_hex`. Icons inside are centered and rendered in white or `secondary_color_hex`.

### Pill-Shaped Tags
Small, 24px height tags with `label-lg` text. They use a low-opacity tint of the Primary Indigo for the background and full-opacity Indigo for the text.

### Bottom Navigation
A clean, fixed bar using a blurred version of the background (`surface`) color. Icons use the squircle geometry for their active states (a subtle background highlight). Navigation items: Home, Folders, Graph, Settings.

### Graph Nodes
Circles (1:1 aspect ratio) representing vault items. They are color-mapped to their content type. The center node (current selection) is larger with a subtle outer glow of its own color.

### Input Fields
Soft-rounded (12px) fields with a `neutral.outline` that thickens and changes to `primary_color_hex` on focus.