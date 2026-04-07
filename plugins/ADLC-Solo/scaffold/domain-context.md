# Domain Context

## Business Domain
{{Describe what this software does and who uses it. 2-3 paragraphs.}}

## Key Entities
{{List the main domain objects and their relationships.}}

Example:
- **User**: Has a role (admin, member, viewer). Belongs to one Organization.
- **Organization**: Has many Users. Owns many Projects.
- **Project**: Belongs to one Organization. Has many Tasks.

## Business Rules
{{List rules that must always be true. These inform acceptance criteria.}}

Example:
- A User cannot belong to more than one Organization at a time.
- Deleting an Organization soft-deletes all its Projects.
- Only admin Users can invite new members.

## External Systems
{{List APIs, services, and databases this system integrates with.}}

Example:
- **Stripe**: Payment processing. Webhook for subscription events.
- **SendGrid**: Transactional email.
- **PostgreSQL**: Primary data store.

## Architecture Decisions
{{Key architectural choices that affect how features are built.}}

Example:
- Event-driven: domain events published on state changes, consumed by handlers.
- Repository pattern: all database access through repository interfaces.
- Feature flags: new features behind flags, enabled per-organization.
