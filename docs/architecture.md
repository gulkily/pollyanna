# Pollyanna Architecture

## Overview
Pollyanna is a decentralized web framework for creating online social spaces with a focus on consent, accessibility, and user empowerment. The architecture is designed to be modular, secure, and highly portable, prioritizing text-based content and universal accessibility.

## Core Components

### 1. Content Management System
- **Text Storage**: Raw text files stored in `html/txt/`
- **Image Management**: Image files stored in `html/image/`
- **Template System**: Located in `default/template/` 
  - Perl-based templating engine
  - Customizable themes and layouts
  - Support for text-art and preserved whitespace

### 2. User Management
- **Identity System**
  - Private key-based user accounts
  - No mandatory registration or email requirement
  - Portable identities across instances
  - Client-side key management

### 3. Data Storage
- **File System Structure**
  - Text-based storage for maximum portability
  - Hierarchical organization
  - Built-in support for archiving and replication

### 4. Security Layer
- **Authentication**
  - Digital signature verification
  - Private key-based identity
  - Optional JavaScript module for client-side signatures

- **Access Control**
  - Configurable access levels
  - Spam prevention mechanisms
  - Fine-grained permission system

### 5. Interface Layer
- **Multi-Modal Access**
  - HTML-based web interface
  - Text-mode interface
  - Telnet support
  - No-JS fallback support

- **Accessibility Features**
  - Screen reader compatibility
  - Keyboard navigation
  - Legacy browser support
  - Mobile device support

### 6. Voting and Consensus System
- **Transparent Voting**
  - Auditable voting logs
  - Meta-moderation capabilities
  - Vote comparison for content discovery
  - Anti-tampering validation chain

### 7. Data Validation
- **Chain Log System**
  - Timestamp validation
  - Content integrity verification
  - Deletion tracking
  - Audit trail maintenance

## System Requirements

### Server-side
- Web server with standard access.log capability
- Optional PHP/SSI support
- Perl interpreter
- Bash shell

### Client-side
- Any web browser (including legacy browsers)
- Optional JavaScript support
- Text-mode clients supported (Lynx, w3m, etc.)

## Data Flow

1. **Content Creation**
   ```
   User Input -> Validation -> Digital Signature -> Storage -> Template Processing -> Display
   ```

2. **Content Retrieval**
   ```
   Request -> Access Check -> Content Fetch -> Template Application -> Delivery
   ```

3. **Voting Process**
   ```
   Vote Cast -> Signature Verification -> Log Update -> Meta-moderation -> Result Calculation
   ```

## Scalability and Replication

The architecture supports horizontal scaling through:
- Complete data portability
- Instance replication
- User account portability across instances
- Content synchronization capabilities

## Security Considerations

1. **Data Integrity**
   - Digital signatures for content verification
   - Timestamp validation chain
   - Audit logs for all operations

2. **Privacy**
   - User-controlled data access
   - No central identity authority
   - Optional registration
   - Minimal data collection

3. **Attack Surface Reduction**
   - Optional static HTML operation
   - Minimal server-side processing
   - Optional JavaScript
   - Configurable security features

## Customization and Extension

The architecture supports customization through:
- Theme system
- Template modification
- Module system
- Configuration options
- Custom client implementations

## Monitoring and Maintenance

- Built-in statistics tracking
- Log management
- Debug mode support
- Health check capabilities
- Performance monitoring tools

## Future Considerations

1. **Scalability Improvements**
   - Enhanced replication mechanisms
   - Better caching strategies
   - Optimized storage formats

2. **Feature Extensions**
   - Additional authentication methods
   - Enhanced spam prevention
   - Improved content discovery
   - Advanced moderation tools

3. **Integration Capabilities**
   - API extensions
   - Additional protocol support
   - Enhanced interoperability

## Design Principles

The architecture adheres to these core principles:
1. User empowerment and consent
2. Universal accessibility
3. Data portability
4. System transparency
5. Security by design
6. Minimal dependencies
7. Maximum compatibility
