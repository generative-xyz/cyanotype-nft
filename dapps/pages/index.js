import Home from '../src/components/Home.jsx';
import {useEffect, useState} from 'react';
import {MetaMaskProvider} from "@metamask/sdk-react";

function App() {
  const [showChild, setShowChild] = useState(false);
  useEffect(() => {
    setShowChild(true);
  }, []);

  if (!showChild) {
    return null;
  }
  if (typeof window === 'undefined') {
    return <></>;
  } else {
      return (
          <MetaMaskProvider
              sdkOptions={{
                  dappMetadata: {
                      name: "Example React Dapp",
                      url: window.location.href,
                  },
                  infuraAPIKey: 'http://127.0.0.1:8545/',
                  // Other options.
              }}
          >
              <Home />
          </MetaMaskProvider>
      );
  }
}

export default App;
