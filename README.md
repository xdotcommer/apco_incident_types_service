# APCO Incident Types Service

A Ruby on Rails microservice that provides APCO (Association of Public-Safety Communications Officials) emergency incident type information. This service uses Redis as an in-memory store to efficiently serve APCO codes and descriptions.

## Overview

This Rails service manages and serves APCO incident type information without traditional database persistence, utilizing Redis for:
- Fast in-memory APCO code lookups
- Call type to APCO code mappings
- Incident type descriptions
- Efficient data retrieval

## Requirements

- Ruby 3.3.0
- Rails 8.x
- Redis Server
- Bundler

## Installation

1. Clone the repository:
```bash
git clone https://github.com/xdotcommer/apco_incident_types_service
cd apco_incident_types_service
```

2. Install dependencies:
```bash
bundle install
```

3. Configure Redis connection:
Create `config/redis.yml`:
```yaml
development:
  url: redis://localhost:6379/0
test:
  url: redis://localhost:6379/1
production:
  url: <%= ENV['REDIS_URL'] %>
```

## Redis Storage Structure

The service uses Redis with the following key structure:
```
apco:call_types:{type} -> Hash containing code, description, and notes
apco:mappings:{original_type} -> Standardized APCO type
```

Example:
```ruby
# Redis data structure
{
  "apco:call_types:MEDICAL" => {
    code: "101",
    description: "Medical Emergency",
    notes: "Requires immediate response"
  }
}
```

## API Endpoints

### Health Check
```http
GET /health
```
Returns service health status including Redis connection state.

Response:
```json
{
  "status": "ok",
  "redis": "connected"
}
```

### Get APCO Call Type Information
```http
GET /api/v1/call_types/:type
```

Retrieves APCO information for a specific call type.

Example Request:
```http
GET /api/v1/call_types/MEDICAL
```

Example Response:
```json
{
  "code": "101",
  "description": "Medical Emergency",
  "notes": "Requires immediate response"
}
```

## Development

1. Start Redis server:
```bash
redis-server
```

2. Start the Rails server:
```bash
rails server -p 4000
```

3. Run the test suite:
```bash
bundle exec rspec
```

## Configuration

Environment variables:
```env
REDIS_URL=redis://localhost:6379/0
PORT=4000
RAILS_ENV=development
```

## Testing

Tests are written in RSpec and use a separate Redis database:

```bash
bundle exec rspec
```

Key test areas:
- API endpoints
- Redis integration
- Call type mappings
- Error scenarios

## Redis Management

Load initial APCO data into Redis:
```bash
rails apco:load_data
```

Clear Redis store:
```bash
rails apco:clear_data
```

## Error Handling

The service handles:
- Redis connection issues
- Missing APCO codes
- Invalid call types
- Cache misses

## Docker Support

1. Build the image:
```bash
docker-compose build
```

2. Run the services:
```bash
docker-compose up
```

## Monitoring

The service provides:
- Health check endpoint
- Redis connection status
- Cache hit/miss metrics
- Response time monitoring

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Related Services

- [CAD Call Simulator](https://github.com/xdotcommer/cad_call_simulator) - A Python tool for simulating incident data
- [Call Service](https://github.com/xdotcommer/call_service) - Main call processing service
- [APCO Service](https://github.com/xdotcommer/apco_incident_types_service) - APCO code lookup service
- [Call Logger](https://github.com/xdotcommer/call_logger) - Persistent storage service for emergency call data

This microservices ecosystem provides a complete solution for:
- Simulating emergency calls (CAD Call Simulator)
- Processing and routing calls (Call Service)
- Standardizing call types (APCO Service)
- Storing call history (Call Logger)

## Acknowledgments

- APCO International for standardized incident type codes
- Redis community for the robust in-memory data store
- Ruby on Rails community
