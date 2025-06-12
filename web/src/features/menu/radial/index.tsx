import { Box, createStyles } from '@mantine/core';
import { useEffect, useState } from 'react';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import { useNuiEvent } from '../../../hooks/useNuiEvent';
import { fetchNui } from '../../../utils/fetchNui';
import { isIconUrl } from '../../../utils/isIconUrl';
import ScaleFade from '../../../transitions/ScaleFade';
import type { RadialMenuItem } from '../../../typings';
import { useLocales } from '../../../providers/LocaleProvider';
import LibIcon from '../../../components/LibIcon';

const MENU_SIZE = 360;
const CENTER = MENU_SIZE / 2;
const OUTER_RADIUS = 180;
const INNER_RADIUS = 70;
const CENTER_RADIUS = 32;
const ICON_SIZE = 20;
const PAGE_ITEMS = 8;
const SECTOR_GAP_DEG = 0;
const MAX_LABEL_LINE_LENGTH = 12;

const useStyles = createStyles(() => ({
  wrapper: {
    position: 'absolute',
    top: '50%',
    left: '50%',
    transform: 'translate(-50%, -50%)',
    pointerEvents: 'auto',
    zIndex: 1000,
    padding: 16,
  },
  sector: {
    transition: 'fill 0.2s, filter 0.2s',
    cursor: 'pointer',
    filter: 'drop-shadow(0 2px 8px rgba(0,0,0,0.10))',
    '&:hover': {
      fill: '#A6ADC8',
      filter: 'brightness(1.15) drop-shadow(0 4px 16px rgba(203,166,247,0.18))',
    },
  },
  backgroundCircle: {
    fill: 'rgba(49,50,68,0.75)',
  },
  centerCircle: {
    fill: '#CBA6F7',
    stroke: '#313244',
    strokeWidth: 2,
    cursor: 'pointer',
    transition: 'fill 0.2s',
    '&:hover': {
      fill: '#B4BEFE',
    },
  },
  centerIconContainer: {
    position: 'absolute',
    top: '50%',
    left: '50%',
    transform: 'translate(-50%, -50%)',
    pointerEvents: 'none',
    zIndex: 2,
  },
  centerIcon: {
    color: '#313244',
    fontSize: 28,
  },
  label: {
    fontSize: 12,
    fill: '#CDD6F4',
    pointerEvents: 'none',
    userSelect: 'none',
    fontWeight: 500,
    textShadow: '0 1px 2px rgba(0,0,0,0.25)',
  },
}));

function getSectorPath(
  cx: number,
  cy: number,
  r1: number,
  r2: number,
  startAngle: number,
  endAngle: number,
  angleGap: number = 2 
): string {
  const toRad = (deg: number) => (Math.PI / 180) * deg;

  const adjustedStart = startAngle + angleGap / 2;
  const adjustedEnd = endAngle - angleGap / 2;

  const x1 = cx + r1 * Math.cos(toRad(adjustedStart));
  const y1 = cy + r1 * Math.sin(toRad(adjustedStart));

  const x2 = cx + r2 * Math.cos(toRad(adjustedStart));
  const y2 = cy + r2 * Math.sin(toRad(adjustedStart));

  const x3 = cx + r2 * Math.cos(toRad(adjustedEnd));
  const y3 = cy + r2 * Math.sin(toRad(adjustedEnd));

  const x4 = cx + r1 * Math.cos(toRad(adjustedEnd));
  const y4 = cy + r1 * Math.sin(toRad(adjustedEnd));

  const largeArc = adjustedEnd - adjustedStart > 180 ? 1 : 0;

  return [
    `M ${x1} ${y1}`,
    `L ${x2} ${y2}`,
    `A ${r2} ${r2} 0 ${largeArc} 1 ${x3} ${y3}`,
    `L ${x4} ${y4}`,
    `A ${r1} ${r1} 0 ${largeArc} 0 ${x1} ${y1}`,
    'Z'
  ].join(' ');
}

const RadialMenu: React.FC = () => {
  const { classes } = useStyles();
  const { locale } = useLocales();
  const [visible, setVisible] = useState(false);
  const [menuItems, setMenuItems] = useState<RadialMenuItem[]>([]);
  const [menu, setMenu] = useState<{ items: RadialMenuItem[]; sub?: boolean; page: number }>({
    items: [],
    sub: false,
    page: 1,
  });

  const changePage = async (increment?: boolean) => {
    setVisible(false);
    const didTransition: boolean = await fetchNui('radialTransition');
    if (!didTransition) return;
    setVisible(true);
    setMenu({ ...menu, page: increment ? menu.page + 1 : menu.page - 1 });
  };

  useEffect(() => {
    if (menu.items.length <= PAGE_ITEMS) return setMenuItems(menu.items);
    const items = menu.items.slice(
      PAGE_ITEMS * (menu.page - 1) - (menu.page - 1),
      PAGE_ITEMS * menu.page - menu.page + 1
    );
    if (PAGE_ITEMS * menu.page - menu.page + 1 < menu.items.length) {
      items[items.length - 1] = { icon: 'ellipsis-h', label: locale.ui.more, isMore: true };
    }
    setMenuItems(items);
  }, [menu.items, menu.page]);

  useNuiEvent('openRadialMenu', async (data: { items: RadialMenuItem[]; sub?: boolean; option?: string } | false) => {
    if (!data) return setVisible(false);
    let initialPage = 1;
    if (data.option) {
      data.items.findIndex(
        (item, index) => item.menu == data.option && (initialPage = Math.floor(index / PAGE_ITEMS) + 1)
      );
    }
    setMenu({ ...data, page: initialPage });
    setVisible(true);
  });

  useNuiEvent('refreshItems', (data: RadialMenuItem[]) => {
    setMenu({ ...menu, items: data });
  });

  // --- UI ---
  const sectorCount = Math.max(menuItems.length, 3);
  const anglePerSector = 360 / sectorCount;
  const gap = SECTOR_GAP_DEG;

  function splitTextIntoLines(label: string, MAX_LABEL_LINE_LENGTH: number): string[] {
    if (!label) return [''];
    const words = label.split(' ');
    const lines: string[] = [];
    let currentLine = '';

    for (const word of words) {
      // If adding the next word exceeds the max length, start a new line
      if ((currentLine + (currentLine ? ' ' : '') + word).length > MAX_LABEL_LINE_LENGTH) {
        if (currentLine) lines.push(currentLine);
        // If the word itself is longer than the max, split it forcibly
        if (word.length > MAX_LABEL_LINE_LENGTH) {
          let start = 0;
          while (start < word.length) {
            lines.push(word.slice(start, start + MAX_LABEL_LINE_LENGTH));
            start += MAX_LABEL_LINE_LENGTH;
          }
          currentLine = '';
        } else {
          currentLine = word;
        }
      } else {
        currentLine += (currentLine ? ' ' : '') + word;
      }
    }
    if (currentLine) lines.push(currentLine);
    return lines;
  }


  return visible ? (
    <Box className={classes.wrapper} style={{ width: MENU_SIZE, height: MENU_SIZE }}>
      <ScaleFade visible={visible}>
        <svg width={MENU_SIZE} height={MENU_SIZE} viewBox={`0 0 ${MENU_SIZE} ${MENU_SIZE}`}>
          {/* Background circle */}
          <circle
            cx={CENTER}
            cy={CENTER}
            r={OUTER_RADIUS}
            className={classes.backgroundCircle}
            style={{ filter: 'blur(1px)' }}
          />
          {/* Sectors */}
          {menuItems.map((item, idx) => {
            const startAngle = idx * anglePerSector + gap / 2 - 90;
            const endAngle = (idx + 1) * anglePerSector - gap / 2 - 90;
            const midAngle = (startAngle + endAngle) / 2;
            const iconX = CENTER + Math.cos((Math.PI / 180) * midAngle) * ((OUTER_RADIUS + INNER_RADIUS) / 2);
            const iconY = CENTER + Math.sin((Math.PI / 180) * midAngle) * ((OUTER_RADIUS + INNER_RADIUS) / 2);
            const lines = splitTextIntoLines(item.label, MAX_LABEL_LINE_LENGTH);
            const labelY = iconY + ICON_SIZE / 1.2;

            return (
              <g
                key={idx}
                className={classes.sector}
                onClick={async () => {
                  const clickIndex = menu.page === 1 ? idx : PAGE_ITEMS * (menu.page - 1) - (menu.page - 1) + idx;
                  if (!item.isMore) fetchNui('radialClick', clickIndex);
                  else await changePage(true);
                }}
              >
                <path
                  d={getSectorPath(CENTER, CENTER, INNER_RADIUS, OUTER_RADIUS, startAngle, endAngle)}
                  fill="#45475A"
                />
                {/* Icon */}
                {typeof item.icon === 'string' && isIconUrl(item.icon) ? (
                  <image
                    href={item.icon}
                    width={ICON_SIZE}
                    height={ICON_SIZE}
                    x={iconX - ICON_SIZE / 2}
                    y={iconY - ICON_SIZE / 2}
                  />
                ) : (
                  <LibIcon
                    x={iconX - ICON_SIZE / 2}
                    y={iconY - ICON_SIZE / 2}
                    icon={item.icon as IconProp}
                    width={ICON_SIZE}
                    height={ICON_SIZE}
                    fixedWidth
                  />
                )}
                {/* Label */}
                <text
                  x={iconX}
                  y={labelY}
                  className={classes.label}
                  textAnchor="middle"
                  dominantBaseline="hanging"
                >
                  {lines.map((line, i) => (
                    <tspan
                      key={i}
                      x={iconX}
                      dy={i === 0 ? 0 : '1.2em'}
                      style={{
                        fontSize: 11,
                        fontWeight: 500,
                        fill: '#CDD6F4',
                        textShadow: '0 1px 2px rgba(0,0,0,0.25)',
                        maxWidth: 60, // px, adjust as needed
                        overflow: 'hidden',
                        textOverflow: 'ellipsis',
                        whiteSpace: 'pre',
                      }}
                    >
                      {line.length > MAX_LABEL_LINE_LENGTH + 2 ? line.slice(0, MAX_LABEL_LINE_LENGTH) + '…' : line}
                    </tspan>
                  ))}
                </text>
              </g>
            );
          })}
          {/* Center button */}
          <g
            onClick={async () => {
              if (menu.page > 1) await changePage();
              else if (menu.sub) fetchNui('radialBack');
              else {
                setVisible(false);
                fetchNui('radialClose');
              }
            }}
            style={{ cursor: 'pointer' }}
          >
            <circle cx={CENTER} cy={CENTER} r={CENTER_RADIUS} className={classes.centerCircle} />
            <foreignObject
              x={CENTER - 16}
              y={CENTER - 16}
              width={32}
              height={32}
              style={{ pointerEvents: 'none' }}
            >
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', width: 32, height: 32 }}>
                <LibIcon
                  icon={!menu.sub && menu.page < 2 ? 'xmark' : 'arrow-rotate-left'}
                  fixedWidth
                  color="#313244"
                  size="lg"
                  style={{ width: 32, height: 32, fontSize: 24 }}
                />
              </div>
            </foreignObject>
          </g>
        </svg>
        {/* Center icon */}
        {/* <div className={classes.centerIconContainer}>
          <LibIcon
            icon={!menu.sub && menu.page < 2 ? 'xmark' : 'arrow-rotate-left'}
            fixedWidth
            className={classes.centerIcon}
            color="#313244"
            size="lg"
          />
        </div> */}
      </ScaleFade>
    </Box>
  ) : null;
};

export default RadialMenu;
