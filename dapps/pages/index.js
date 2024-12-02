import Install from '../src/components/Install.jsx';
import Home from '../src/components/Home.jsx';
import { useState, useEffect } from 'react';

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
    if (window.ethereum) {
      return <Home />;
    } else {
      return <Install />;
    }
  }
}

export default App;
