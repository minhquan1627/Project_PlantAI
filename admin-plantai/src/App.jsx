import './App.css';
import React, { useState } from 'react'; // Chuyển sang dùng Hook cho hiện đại
import { BrowserRouter } from 'react-router-dom';
import MyProvider from './contexts/MyProvider';

import Login from './components/LoginandRegisterComponent';
import Main from './components/MainComponent';

const App = () => {
  // Trạng thái đăng nhập: false là chưa vào, true là đã vào
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  return (
    <MyProvider>
      <BrowserRouter>
        {isLoggedIn ? (
          // Nếu đã đăng nhập thành công -> Hiện trang chủ Admin
          <Main onLogout={() => setIsLoggedIn(false)} />
        ) : (
          // Nếu chưa -> Hiện trang Login và truyền hàm "onLoginSuccess" vào
          <Login onLoginSuccess={() => setIsLoggedIn(true)} />
        )}
      </BrowserRouter>
    </MyProvider>
  );
}

export default App;