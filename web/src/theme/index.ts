import { MantineThemeOverride } from '@mantine/core';

export const theme: MantineThemeOverride = {
  colorScheme: 'dark',
  fontFamily: 'Roboto',
  shadows: { sm: '1px 1px 3px rgba(0, 0, 0, 0.5)' },
  colors: {
    // Catppuccin Mocha palette
    base: [
      '#1E1E2E', // base
      '#181825', // mantle
      '#11111B', // crust
      '#313244', // surface0
      '#45475A', // surface1
      '#585B70', // surface2
      '#6C7086', // surface3
      '#7F849C', // overlay0
      '#9399B2', // overlay1
      '#A6ADC8', // overlay2
    ],
    text: [
      '#CDD6F4', // text
      '#BAC2DE', // subtext0
      '#A6ADC8', // subtext1
      '#7F849C', // overlay0
      '#6C7086', // overlay1
      '#585B70', // surface2
      '#45475A', // surface1
      '#313244', // surface0
      '#1E1E2E', // base
      '#11111B', // crust
    ],
    accent: [
      '#F5E0DC', // rosewater
      '#F2CDCD', // flamingo
      '#F5C2E7', // pink
      '#CBA6F7', // mauve
      '#F38BA8', // red
      '#FAB387', // peach
      '#F9E2AF', // yellow
      '#A6E3A1', // green
      '#94E2D5', // teal
      '#89B4FA', // blue
    ],
  },
  primaryColor: 'accent',
  primaryShade: 3, // mauve
  components: {
    Button: {
      styles: {
        root: {
          backgroundColor: '#313244', // surface0
          border: '1px solid #45475A', // surface1
          '&:hover': {
            backgroundColor: '#45475A', // surface1
          },
        },
      },
    },
    Paper: {
      styles: {
        root: {
          backgroundColor: '#1E1E2E', // base
          color: '#CDD6F4', // text
        },
      },
    },
    Modal: {
      styles: {
        modal: {
          backgroundColor: '#1E1E2E', // base
        },
        header: {
          backgroundColor: '#313244', // surface0
        },
      },
    },
    Input: {
      styles: {
        input: {
          backgroundColor: '#313244', // surface0
          borderColor: '#45475A', // surface1
          color: '#CDD6F4', // text
          '&:focus': {
            borderColor: '#CBA6F7', // mauve
          },
        },
      },
    },
    Text: {
      styles: {
        root: {
          color: '#CDD6F4', // text
          '& strong': {
            color: '#89B4FA', // blue
          },
          '& em': {
            color: '#F5C2E7', // pink
          },
        },
      },
    },
    Box: {
      styles: {
        root: {
          backgroundColor: '#313244', // surface0
          color: '#CDD6F4', // text
        },
      },
    },
  },
};
