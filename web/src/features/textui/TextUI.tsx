import React from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { Box, createStyles, Group } from '@mantine/core';
import ReactMarkdown from 'react-markdown';
import ScaleFade from '../../transitions/ScaleFade';
import remarkGfm from 'remark-gfm';
import type { TextUiPosition, TextUiProps } from '../../typings';
import MarkdownComponents from '../../config/MarkdownComponents';
import LibIcon from '../../components/LibIcon';

const useStyles = createStyles((theme, params: { position?: TextUiPosition }) => ({
  wrapper: {
    height: '100%',
    width: '100%',
    position: 'absolute',
    display: 'flex',
    alignItems:
      params.position === 'top-center' ? 'baseline' :
      params.position === 'bottom-center' ? 'flex-end' : 'center',
    justifyContent:
      params.position === 'right-center' ? 'flex-end' :
      params.position === 'left-center' ? 'flex-start' : 'center',
  },
  container: {
    fontSize: 15,
    lineHeight: 1.6,
    padding: 16,
    margin: 8,
    background: 'rgba(49, 50, 68, 0.98)',
    color: '#CDD6F4',
    fontFamily: 'Roboto, sans-serif',
    borderRadius: theme.radius.lg,
    boxShadow: '0 6px 24px rgba(0,0,0,0.25)',
    border: '2px solid #45475A',
    backdropFilter: 'blur(8px)',
    WebkitBackdropFilter: 'blur(8px)',
    maxWidth: '90vw',
    minWidth: 220,
    wordBreak: 'break-word',
    transition: 'box-shadow 0.2s, background 0.2s',
    pointerEvents: 'auto', // allow interaction
    '& strong': {
      color: '#89B4FA',
      fontWeight: 700,
    },
    '& em': {
      color: '#F5C2E7',
      fontStyle: 'italic',
    },
  },
}));

const TextUI: React.FC = () => {
  const [data, setData] = React.useState<TextUiProps>({
    text: '',
    position: 'right-center',
  });
  const [visible, setVisible] = React.useState(false);
  const { classes } = useStyles({ position: data.position });

  useNuiEvent<TextUiProps>('textUi', (data) => {
    if (!data.position) data.position = 'right-center'; // Default right position
    setData(data);
    setVisible(true);
  });

  useNuiEvent('textUiHide', () => setVisible(false));

  return (
    <>
      <Box className={classes.wrapper}>
        <ScaleFade visible={visible}>
          <Box style={data.style} className={classes.container} role="status" aria-live='polite'>
            <Group spacing={12}>
              {data.icon && (
                <LibIcon
                  icon={data.icon}
                  fixedWidth
                  size="lg"
                  animation={data.iconAnimation}
                  style={{
                    color: data.iconColor,
                    alignSelf: !data.alignIcon || data.alignIcon === 'center' ? 'center' : 'start',
                    minWidth: 16,
                    minHeight: 32,
                    fontSize: 24,
                  }}
                />
              )}
              <ReactMarkdown components={MarkdownComponents} remarkPlugins={[remarkGfm]}>
                {data.text}
              </ReactMarkdown>
            </Group>
          </Box>
        </ScaleFade>
      </Box>
    </>
  );
};

export default TextUI;
