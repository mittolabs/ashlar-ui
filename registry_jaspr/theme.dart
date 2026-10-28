// Ashlar UI for Jaspr: Theme. Copied into your app by `ashlar init`; it is yours to change.
//
// Every colour, corner and text size the components use comes from here, as CSS
// variables: neutral, light and dark. Dark follows the system unless the page sets
// data-theme="light" or data-theme="dark" on <html>.

import 'package:jaspr/dom.dart';

const _light = {
  '--ash-background': '#ffffff',
  '--ash-foreground': '#0a0a0a',
  '--ash-card': '#ffffff',
  '--ash-card-foreground': '#0a0a0a',
  '--ash-popover': '#ffffff',
  '--ash-popover-foreground': '#0a0a0a',
  '--ash-primary': '#171717',
  '--ash-primary-foreground': '#fafafa',
  '--ash-secondary': '#f5f5f5',
  '--ash-secondary-foreground': '#171717',
  '--ash-muted': '#f5f5f5',
  '--ash-muted-foreground': '#707070',
  '--ash-accent': '#f5f5f5',
  '--ash-accent-foreground': '#171717',
  '--ash-destructive': '#e7000b',
  '--ash-destructive-foreground': '#ffffff',
  '--ash-border': '#e5e5e5',
  '--ash-input': '#e5e5e5',
  '--ash-ring': '#737373',
  '--ash-chart-1': '#f54a00',
  '--ash-chart-2': '#009689',
  '--ash-chart-3': '#104e64',
  '--ash-chart-4': '#ffb900',
  '--ash-chart-5': '#fe9a00',
  '--ash-overlay': 'rgb(0 0 0 / 0.5)',
};

const _dark = {
  '--ash-background': '#0a0a0a',
  '--ash-foreground': '#fafafa',
  '--ash-card': '#171717',
  '--ash-card-foreground': '#fafafa',
  '--ash-popover': '#171717',
  '--ash-popover-foreground': '#fafafa',
  '--ash-primary': '#e5e5e5',
  '--ash-primary-foreground': '#171717',
  '--ash-secondary': '#262626',
  '--ash-secondary-foreground': '#fafafa',
  '--ash-muted': '#262626',
  '--ash-muted-foreground': '#a1a1a1',
  '--ash-accent': '#262626',
  '--ash-accent-foreground': '#fafafa',
  '--ash-destructive': '#ff6467',
  // Red-950: white on this red would be 2.9:1, under the 4.5 text needs.
  '--ash-destructive-foreground': '#460809',
  '--ash-border': 'rgb(255 255 255 / 0.1)',
  '--ash-input': 'rgb(255 255 255 / 0.15)',
  '--ash-ring': '#737373',
  '--ash-chart-1': '#1447e6',
  '--ash-chart-2': '#00bc7d',
  '--ash-chart-3': '#fe9a00',
  '--ash-chart-4': '#ad46ff',
  '--ash-chart-5': '#ff2056',
  '--ash-overlay': 'rgb(0 0 0 / 0.7)',
};

const _shape = {
  // The base corner. Controls use --ash-radius-md; cards and dialogs --ash-radius-xl.
  '--ash-radius': '10px',
  '--ash-radius-sm': 'calc(var(--ash-radius) - 4px)',
  '--ash-radius-md': 'calc(var(--ash-radius) - 2px)',
  '--ash-radius-lg': 'var(--ash-radius)',
  '--ash-radius-xl': 'calc(var(--ash-radius) + 4px)',
  '--ash-font':
      'ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
  '--ash-font-mono': 'ui-monospace, SFMono-Regular, Menlo, Consolas, monospace',
  '--ash-shadow-sm': '0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1)',
  '--ash-shadow-lg': '0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)',
  // The ring a control shows when it has keyboard focus.
  '--ash-focus': '0 0 0 3px color-mix(in srgb, var(--ash-ring) 50%, transparent)',
};

/// The theme's variables and the page's base: its colours, text and box sizing.
@css
List<StyleRule> get ashlarTheme => [
  css(':root').styles(raw: {..._shape, ..._light, 'color-scheme': 'light'}),
  css.media(MediaQuery.all(prefersColorScheme: ColorScheme.dark), [
    css(':root:not([data-theme="light"])').styles(raw: {..._dark, 'color-scheme': 'dark'}),
  ]),
  css(':root[data-theme="dark"]').styles(raw: {..._dark, 'color-scheme': 'dark'}),
  css('*, *::before, *::after').styles(raw: {'box-sizing': 'border-box'}),
  css('html, body').styles(
    raw: {
      'margin': '0',
      'background': 'var(--ash-background)',
      'color': 'var(--ash-foreground)',
      'font-family': 'var(--ash-font)',
      'font-size': '16px',
      'line-height': '1.5',
      '-webkit-font-smoothing': 'antialiased',
    },
  ),
  // Read by screen readers, not drawn.
  css('.ash-sr-only').styles(
    raw: {
      'position': 'absolute',
      'width': '1px',
      'height': '1px',
      'padding': '0',
      'margin': '-1px',
      'overflow': 'hidden',
      'clip': 'rect(0, 0, 0, 0)',
      'white-space': 'nowrap',
      'border': '0',
    },
  ),
  css('.ash-muted').styles(raw: {'color': 'var(--ash-muted-foreground)'}),
  css('.ash-mono').styles(raw: {'font-family': 'var(--ash-font-mono)'}),
];
