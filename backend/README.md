# Backend Architecture
The Ventura backend follows a Microservices Architecture consisting of four independent services:

| Service | Port | Responsibility |
|----------|----------|----------|
| API Gateway | 3000 | Routes incoming requests to the appropriate service |
| Auth Service | 3001 | Authentication, authorization, and JWT management |
| Finance Service | 3002 | Budgeting, expense tracking, and financial management |
| Travel Service | 3003 | Travel planning and recommendation generation |

## Request Flow
\```text
Client
   │
   ▼
API Gateway (3000)
   │
   ├──► Auth Service (3001)
   ├──► Finance Service (3002)
   └──► Travel Service (3003)
\```

All client requests pass through the API Gateway, which forwards them to the corresponding microservice.
