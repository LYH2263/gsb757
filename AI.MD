1. 请先阅读我的rule user_rule.md文件    ，然后根据我的rule在项目下按照规范完成开发，
2. 所有的任务完成后,输出readme.md
3. 输出result.md 根据result.md中的内容，输出最终的开发结果

以下是我的prompt

简易版线上书店系统开发
本学期《Java Web开发技术》课程中，我们学习了前端开发基础知识、JSP编程、Servlet开发、AJAX技术等，已经初步具备了开发Java Web应用的能力。开发中可以使用Servlet接收用户请求并处理业务逻辑，JSP或者html+CSS+JS负责视图渲染展示，JavaBean封装业务数据和逻辑，JDBC处理数据库操作。本考核要求使用HTML、CSS、JavaScript、JSP、Servlet和AJAX技术开发一个简易版线上书店系统。项目需实现用户注册、登录、浏览图书列表、购物车管理(包括加入购物车、修改购物车图书、清空购物车、查询购物车)、退出登录等核心功能，考察学生对Java Web开发技术的综合应用能力。
项目实现参考步骤如下：
1.准备开发环境与搭建项目。安装Java Web的开发环境，包括JDK/IDEA/Tomcat/MySQL等。然后创建动态web项目，并对项目目录结构做出规划，参考如下：
BookStore/
├── src/main
│   └──java/ com/bookstore/
│       ├── servlet/      # Servlet类
│       ├── model/      # 实体类
│       ├── dao/        # 数据访问层相关接口和类
│       └── util/        # 工具类
├── src/webapp/
│   ├── css/               # 样式文件
│   ├── js/                # JavaScript文件
│   ├── images/            # 图片资源，比如图书封皮
│   ├── html/              # html文件
│   ├── jsp/               # JSP文件
│   ├── WEB-INF/
│   │   └── web.xml
2.系统功能设计和数据库设计。分析自己要实现的核心功能，进行需求分析，在需求分析的基础上进行数据库设计，注意要能够支持自己的系统功能。例如：本系统的数据表通常包含用户表、图书信息表(需包含图书相关图片)、购物车表。注意表中主键、外键、索引等的设置。
3. 系统开发。实现账号注册、登录、浏览图书、加入购物车、购物车管理、退出登录等功能。包括前端页面开发和Servlet处理逻辑的开发，然后进行样式和交互的优化，使用AJAX优化部分交互功能。比如使用AJAX实现添加购物车：在图书列表页面，点击“加入购物车”按钮，通过AJAX将请求发送到AddToCartServlet(Servlet的名称只是示例)，然后不刷新页面显示添加结果。使用AJAX实现购物车数量修改：在购物车页面，修改数量时，通过AJAX请求UpdateCartServlet，然后局部更新总价。
4.系统测试与调试。测试所有功能，解决常见问题。建一个Maven项目