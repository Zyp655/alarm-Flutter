import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final db = context.read<AppDatabase>();

    var instructor = await (db.select(db.users)
          ..where((u) => u.email.equals('admin@roadmap.system')))
        .getSingleOrNull();

    if (instructor == null) {
      final id = await db.into(db.users).insert(
            UsersCompanion.insert(
              email: 'admin@roadmap.system',
              passwordHash: 'system_user_not_for_login',
              fullName: const Value('Hệ thống Roadmap'),
              role: const Value(2), 
            ),
          );
      instructor = await (db.select(db.users)..where((u) => u.id.equals(id)))
          .getSingle();
    }

    final instructorId = instructor.id;
    final now = DateTime.now();
    final createdCourses = <Map<String, dynamic>>[];

    final backendCourses = [
      {
        'title': 'Git & Version Control',
        'description': 'Quản lý mã nguồn chuyên nghiệp với Git',
        'lessons': [
          'Giới thiệu Git và cài đặt',
          'Git init, add, commit cơ bản',
          'Branching và Merging',
          'Git remote và GitHub',
          'Pull Request workflow',
          'Xử lý conflict',
          'Git rebase và cherry-pick',
          'Git hooks và best practices',
        ],
      },
      {
        'title': 'Ngôn ngữ lập trình (Python/Node.js)',
        'description': 'Nền tảng lập trình Backend',
        'lessons': [
          'Cú pháp cơ bản và biến',
          'Kiểu dữ liệu và cấu trúc dữ liệu',
          'Functions và Modules',
          'OOP: Classes và Objects',
          'Exception Handling',
          'File I/O',
          'Async/Await và Promises',
          'Package Manager (pip/npm)',
          'Virtual environments',
          'Testing cơ bản',
        ],
      },
      {
        'title': 'Database & SQL',
        'description': 'Quản lý dữ liệu với SQL và NoSQL',
        'lessons': [
          'Giới thiệu Database và SQL',
          'CREATE, INSERT, SELECT cơ bản',
          'WHERE, ORDER BY, LIMIT',
          'JOINs và Relationships',
          'Aggregate functions',
          'Subqueries và Views',
          'Indexes và Performance',
          'Transactions và ACID',
          'NoSQL và MongoDB cơ bản',
          'ORM (Sequelize/SQLAlchemy)',
          'Database Design patterns',
        ],
      },
      {
        'title': 'REST API Development',
        'description': 'Xây dựng API chuyên nghiệp',
        'lessons': [
          'HTTP Methods và Status Codes',
          'RESTful conventions',
          'Express.js/Flask setup',
          'Routing và Middleware',
          'Request validation',
          'Error handling',
          'File upload API',
          'Pagination và Filtering',
          'API Versioning',
          'CORS và Security headers',
          'Rate limiting',
          'API Documentation (Swagger)',
        ],
      },
      {
        'title': 'Authentication & Security',
        'description': 'Bảo mật ứng dụng',
        'lessons': [
          'Password hashing (bcrypt)',
          'JWT fundamentals',
          'Access và Refresh tokens',
          'Session management',
          'OAuth 2.0 flow',
          'Social login integration',
          'Role-based access control',
          'Input sanitization',
          'SQL Injection prevention',
          'XSS và CSRF protection',
          'HTTPS và SSL/TLS',
        ],
      },
      {
        'title': 'Caching & Performance',
        'description': 'Tối ưu hiệu năng ứng dụng',
        'lessons': [
          'Caching strategies overview',
          'Redis installation và setup',
          'Key-value operations',
          'Cache patterns (aside, through)',
          'Session storage với Redis',
          'Query optimization',
          'Connection pooling',
          'Lazy loading',
        ],
      },
      {
        'title': 'Testing Backend',
        'description': 'Kiểm thử ứng dụng Backend',
        'lessons': [
          'Unit testing fundamentals',
          'Test frameworks (Jest/Pytest)',
          'Mocking và Stubbing',
          'Integration testing',
          'API endpoint testing',
          'Database testing',
          'Test coverage',
          'TDD workflow',
        ],
      },
      {
        'title': 'Docker & Containerization',
        'description': 'Đóng gói và triển khai với Container',
        'lessons': [
          'Container concepts',
          'Docker installation',
          'Dockerfile basics',
          'Docker images và containers',
          'Docker Compose',
          'Multi-stage builds',
          'Volume và Networking',
          'Docker Hub và Registry',
          'Container orchestration intro',
        ],
      },
      {
        'title': 'CI/CD Pipeline',
        'description': 'Tự động hóa deployment',
        'lessons': [
          'CI/CD concepts',
          'GitHub Actions basics',
          'Automated testing pipeline',
          'Build và artifact',
          'Deployment strategies',
          'Environment variables',
          'Secrets management',
          'Monitoring và Alerts',
        ],
      },
      {
        'title': 'Cloud Services',
        'description': 'Triển khai lên Cloud',
        'lessons': [
          'Cloud computing overview',
          'AWS/GCP/Azure basics',
          'Virtual machines',
          'Managed databases',
          'Object storage (S3)',
          'Serverless functions',
          'Load balancing',
          'DNS và Domain setup',
          'SSL certificates',
          'Cost optimization',
        ],
      },
    ];

    final frontendCourses = [
      {
        'title': 'HTML5 Fundamentals',
        'description': 'Nền tảng cấu trúc web',
        'lessons': [
          'Giới thiệu HTML và cấu trúc trang',
          'Headings, paragraphs, lists',
          'Links và Navigation',
          'Images và Media',
          'Forms và Input types',
          'Semantic HTML5 elements',
          'Tables và Data display',
          'Meta tags và SEO basics',
        ],
      },
      {
        'title': 'CSS3 Styling',
        'description': 'Thiết kế giao diện web',
        'lessons': [
          'CSS Selectors và Specificity',
          'Box Model deep dive',
          'Colors, fonts, typography',
          'Flexbox layout',
          'CSS Grid system',
          'Responsive design',
          'Media queries',
          'CSS Variables',
          'Animations và Transitions',
          'CSS Preprocessors (Sass)',
        ],
      },
      {
        'title': 'JavaScript Core',
        'description': 'Lập trình JavaScript cơ bản',
        'lessons': [
          'Variables và Data types',
          'Operators và Expressions',
          'Control flow (if/else, switch)',
          'Loops và Iteration',
          'Functions và Scope',
          'Arrays và Array methods',
          'Objects và JSON',
          'Error handling',
          'ES6+ features',
          'Modules (import/export)',
        ],
      },
      {
        'title': 'JavaScript Advanced',
        'description': 'JavaScript nâng cao',
        'lessons': [
          'Closures và Hoisting',
          'this keyword và binding',
          'Prototypes và Inheritance',
          'Classes và OOP',
          'Async JavaScript patterns',
          'Promises deep dive',
          'Async/Await',
          'Event Loop',
          'Fetch API và HTTP requests',
          'Web APIs (Storage, Geolocation)',
          'Design patterns',
        ],
      },
      {
        'title': 'TypeScript',
        'description': 'JavaScript với Type Safety',
        'lessons': [
          'TypeScript setup và config',
          'Basic types',
          'Interfaces và Type aliases',
          'Functions typing',
          'Classes với TypeScript',
          'Generics',
          'Union và Intersection types',
          'Type guards',
          'Utility types',
          'Declaration files',
        ],
      },
      {
        'title': 'React Fundamentals',
        'description': 'Xây dựng UI với React',
        'lessons': [
          'React introduction và JSX',
          'Components và Props',
          'State và Lifecycle',
          'Event handling',
          'Conditional rendering',
          'Lists và Keys',
          'Forms trong React',
          'Hooks: useState, useEffect',
          'useContext và useReducer',
          'Custom Hooks',
          'React Router',
          'Performance optimization',
        ],
      },
      {
        'title': 'State Management',
        'description': 'Quản lý state trong ứng dụng',
        'lessons': [
          'State management patterns',
          'Context API advanced',
          'Redux fundamentals',
          'Redux Toolkit',
          'Async actions với Thunk',
          'Zustand basics',
          'React Query/TanStack Query',
          'State normalization',
        ],
      },
      {
        'title': 'Modern CSS & Styling',
        'description': 'CSS Frameworks và Tools',
        'lessons': [
          'Tailwind CSS setup',
          'Utility-first workflow',
          'Responsive với Tailwind',
          'Component styling patterns',
          'CSS-in-JS (Styled Components)',
          'CSS Modules',
          'Design systems',
          'Theming và Dark mode',
        ],
      },
      {
        'title': 'Frontend Testing',
        'description': 'Kiểm thử ứng dụng Frontend',
        'lessons': [
          'Testing fundamentals',
          'Jest configuration',
          'React Testing Library',
          'Component testing',
          'User event testing',
          'Async testing',
          'Mocking APIs',
          'E2E testing với Cypress',
          'Snapshot testing',
        ],
      },
      {
        'title': 'Web Performance',
        'description': 'Tối ưu hiệu năng web',
        'lessons': [
          'Performance metrics',
          'Core Web Vitals',
          'Image optimization',
          'Code splitting',
          'Lazy loading',
          'Bundle analysis',
          'Caching strategies',
          'Service Workers',
          'PWA basics',
        ],
      },
      {
        'title': 'Frontend Deployment',
        'description': 'Triển khai ứng dụng Frontend',
        'lessons': [
          'Build process',
          'Environment configuration',
          'Vercel deployment',
          'Netlify setup',
          'Custom domain',
          'CDN và caching',
          'CI/CD cho Frontend',
          'Monitoring và Analytics',
        ],
      },
    ];

    for (final courseData in [...backendCourses, ...frontendCourses]) {
      final courseId = await db.into(db.courses).insert(
            CoursesCompanion.insert(
              title: courseData['title'] as String,
              description: Value(courseData['description'] as String),
              instructorId: instructorId,
              level: const Value('beginner'),
              isPublished: const Value(true),
              createdAt: now,
            ),
          );

      final moduleId = await db.into(db.modules).insert(
            ModulesCompanion.insert(
              courseId: courseId,
              title: 'Nội dung chính',
              description: const Value('Các bài học trong khóa'),
              orderIndex: 0,
              createdAt: now,
            ),
          );

      final lessons = courseData['lessons'] as List<String>;
      for (var i = 0; i < lessons.length; i++) {
        await db.into(db.lessons).insert(
              LessonsCompanion.insert(
                moduleId: moduleId,
                title: lessons[i],
                type: 'document',
                durationMinutes: const Value(15),
                isFreePreview: Value(i == 0),
                orderIndex: i,
                createdAt: now,
              ),
            );
      }

      createdCourses.add({
        'id': courseId,
        'title': courseData['title'],
        'lessonsCount': lessons.length,
      });
    }

    return Response.json(body: {
      'message': 'Roadmap courses seeded successfully',
      'instructorId': instructorId,
      'coursesCount': createdCourses.length,
      'courses': createdCourses,
    });
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to seed courses: $e'},
    );
  }
}
