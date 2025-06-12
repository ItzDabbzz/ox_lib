import { Checkbox, createStyles } from '@mantine/core';

const useStyles = createStyles((theme) => ({
  root: {
    display: 'flex',
    alignItems: 'center',
  },
  input: {
    backgroundColor: '#1E1E2E', // base
    '&:checked': {
      backgroundColor: '#A6ADC8', // overlay2
      borderColor: '#A6ADC8', // overlay2
    },
  },
  inner: {
    '> svg > path': {
      fill: '#313244', // surface0
    },
  },
}));


const CustomCheckbox: React.FC<{ checked: boolean }> = ({ checked }) => {
  const { classes } = useStyles();
  return (
    <Checkbox
      checked={checked}
      size="md"
      classNames={{ root: classes.root, input: classes.input, inner: classes.inner }}
    />
  );
};

export default CustomCheckbox;
