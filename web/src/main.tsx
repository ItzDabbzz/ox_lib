import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';
import { fas } from '@fortawesome/free-solid-svg-icons';
import { far } from '@fortawesome/free-regular-svg-icons';
import { fab } from '@fortawesome/free-brands-svg-icons';
import { library } from '@fortawesome/fontawesome-svg-core';
import { isEnvBrowser } from './utils/misc';
import LocaleProvider from './providers/LocaleProvider';
import ConfigProvider from './providers/ConfigProvider';

library.add(fas, far, fab);

if (isEnvBrowser()) {
  const root = document.getElementById('root');

  // https://i.imgur.com/iPTAdYV.png - Night time img
  // https://share.sanctumrp.net/view_media.php?user=dabz&file=2a03726e71cf8155.png&raw=1 - Day time img
  root!.style.backgroundImage = 'url("https://share.sanctumrp.net/view_media.php?user=dabz&file=2a03726e71cf8155.png&raw=1")';
  root!.style.backgroundSize = 'cover';
  root!.style.backgroundRepeat = 'no-repeat';
  root!.style.backgroundPosition = 'center';
}

const root = document.getElementById('root');
ReactDOM.createRoot(root!).render(
  <React.StrictMode>
    <LocaleProvider>
      <ConfigProvider>
        <App />
      </ConfigProvider>
    </LocaleProvider>
  </React.StrictMode>
);
