# Simple Bookstore (简易版线上书店)

## 🛠 技术栈 (Tech Stack)
- **Frontend**: JSP (JavaServer Pages), Bootstrap 5, Tailwind CSS, SweetAlert2
- **Backend**: Java Servlet 6.0, JDBC (Maven Project / Tomcat 10)
- **Database**: MySQL 8.0
- **Infrastructure**: Docker, Docker Compose

## 🚀 启动指南 (How to Run)
1. 确保 Docker Desktop 已启动。
2. 在根目录执行：
   ```bash
   docker compose down -v  # 清理旧数据（可选）
   docker compose up --build
   ```
3. 等待容器启动完成... Tomcat 启动可能需要几秒钟。

## 🔗 服务地址 (Services)
- **Bookstore App**: [http://localhost:8081](http://localhost:8081)
  - 默认起始页为登录页。
- **Database**: localhost:3307 (user: root / pass: root)

## 🧪 测试账号
- **Admin**: admin / 123456
- **Test User**: 可在登录页自行尝试注册 (目前注册功能复用 AuthServlet，或直接使用 Admin 测试)。

## 📂 项目结构
```
BookStore/
├── backend/            # Java Web Application
│   ├── src/main/java/  # Servlet & Beans (Model 2)
│   ├── src/main/webapp/# JSP Pages & Static Resources
│   └── Dockerfile      # Tomcat Build
├── database/           # Database Init Scripts
└── docker-compose.yml  # Container Orchestration
```

## ✅ 功能列表
- **用户认证**: 登录/退出 (Session 管理)
- **图书浏览**: 响应式网格布局 (Bootstrap + Tailwind)
- **购物车**: 添加商品、移除商品、计算总价
- **立即结算**: 结账流程 demo (SweetAlert2 交互)
- **UI 升级**: 移除原生 alert/confirm，使用美观的 Modal 和 Toast
