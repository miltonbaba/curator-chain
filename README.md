# CuratorChain

[![Clarity](https://img.shields.io/badge/Clarity-3.0-blue.svg)](https://clarity-lang.org/)
[![Stacks](https://img.shields.io/badge/Stacks-Blockchain-orange.svg)](https://stacks.org/)
[![License](https://img.shields.io/badge/License-ISC-green.svg)](LICENSE)

## 🌟 Overview

CuratorChain is a revolutionary blockchain-based content discovery platform that harnesses collective intelligence to surface premium web content through economic incentives and transparent community governance.

The protocol transforms how valuable information spreads across the internet by creating a merit-based ecosystem where knowledge contributors earn recognition and financial rewards, while spam and low-quality content gets naturally filtered out through democratic community voting.

## 🎯 Key Features

### 🔗 **Content Curation**

- Submit valuable web content with metadata (headline, URL, topic)
- Pay-to-post mechanism prevents spam and ensures quality submissions
- Categorized content organization across multiple topics

### 🗳️ **Community Governance**

- Binary voting system (upvote/downvote) for content quality assessment
- Transparent reputation tracking for all participants
- Democratic content filtering through collective intelligence

### 💰 **Economic Incentives**

- Direct monetary rewards for exceptional content creators
- Reputation-based credibility system
- Economic alignment between individual contributions and collective benefit

### 🛡️ **Quality Control**

- Community-driven content flagging system
- Administrative content moderation capabilities
- Permanent audit trail on the blockchain

## 🏗️ Architecture

### Core Components

- **Content Registry**: Comprehensive metadata storage for all curated items
- **Voting System**: Community appraisal mechanism with reputation tracking
- **Reward System**: Direct STX transfers to content creators
- **Governance Layer**: Administrative controls and protocol parameters

### Data Structures

```clarity
;; Primary content storage
curated-items: {
  originator: principal,
  headline: string-ascii 100,
  hyperlink: string-ascii 200,
  topic: string-ascii 20,
  publication-epoch: uint,
  appraisals: int,
  gratuities: uint,
  flags: uint
}

;; Individual voting records
participant-appraisals: {
  participant: principal,
  item-identifier: uint,
  appraisal: int
}

;; Reputation tracking
participant-credibility: {
  participant: principal,
  metric: int
}
```

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks development toolkit
- [Node.js](https://nodejs.org/) (v16 or higher)
- [Stacks Wallet](https://www.hiro.so/wallet) for interaction

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/miltonbaba/curator-chain.git
   cd curator-chain
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Run tests**

   ```bash
   npm test
   ```

4. **Check contracts**

   ```bash
   clarinet check
   ```

### Development Workflow

```bash
# Run tests in watch mode
npm run test:watch

# Generate test coverage report
npm run test:report

# Format Clarity code
clarinet fmt --in-place

# Deploy to devnet
clarinet integrate
```

## 📖 Usage

### Content Submission

```clarity
;; Submit new content for curation
(contract-call? .curator-chain contribute-item 
  "Amazing Blockchain Article"
  "https://example.com/blockchain-guide" 
  "Technology")
```

### Community Voting

```clarity
;; Upvote content (item-id: 1)
(contract-call? .curator-chain appraise-item u1 1)

;; Downvote content (item-id: 1)
(contract-call? .curator-chain appraise-item u1 -1)
```

### Reward Content Creators

```clarity
;; Send 1000 microSTX tip to content creator
(contract-call? .curator-chain reward-originator u1 u1000)
```

### Content Moderation

```clarity
;; Flag inappropriate content
(contract-call? .curator-chain flag-item u1)
```

## 🔍 Read-Only Functions

### Query Content

```clarity
;; Get content details
(contract-call? .curator-chain retrieve-item-details u1)

;; Get top-rated content (limit: 10)
(contract-call? .curator-chain retrieve-top-items u10)

;; Check user's vote on content
(contract-call? .curator-chain retrieve-participant-appraisal 
  'SP1HJQW... u1)
```

### User Information

```clarity
;; Get user reputation
(contract-call? .curator-chain retrieve-participant-credibility 
  'SP1HJQW...)

;; Get total submissions count
(contract-call? .curator-chain retrieve-aggregate-submissions)
```

## ⚙️ Configuration

### Protocol Parameters

- **Submission Charge**: Fee required to submit content (default: 10 microSTX)
- **Minimum URL Length**: 10 characters
- **Maximum Topics**: 10 categories
- **Voting System**: Binary (-1 or +1)

### Default Topics

1. Technology
2. Science  
3. Art
4. Politics
5. Sports

### Administrative Functions

Only the protocol administrator can:

- Adjust submission fees
- Add new content topics (max 10)
- Remove violating content
- Manage protocol parameters

## 🧪 Testing

The project includes comprehensive test coverage using Vitest and Clarinet SDK:

```bash
# Run all tests
npm test

# Run with coverage
npm run test:report

# Watch mode for development
npm run test:watch
```

Test files are located in the `tests/` directory and cover:

- Content submission workflows
- Voting mechanisms
- Reward distributions
- Administrative functions
- Edge cases and error handling

## 📁 Project Structure

```text
curator-chain/
├── contracts/
│   └── curator-chain.clar      # Main smart contract
├── tests/
│   └── curator-chain.test.ts   # Test suite
├── settings/
│   ├── Devnet.toml            # Development network config
│   ├── Testnet.toml           # Testnet configuration
│   └── Mainnet.toml           # Mainnet configuration
├── Clarinet.toml              # Project configuration
├── package.json               # Node.js dependencies
├── tsconfig.json              # TypeScript configuration
└── vitest.config.js           # Test configuration
```

## 🛠️ Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 100 | `ERR_UNAUTHORIZED_ACCESS` | Admin-only function called by non-admin |
| 101 | `ERR_INVALID_SUBMISSION` | Invalid content submission parameters |
| 102 | `ERR_DUPLICATE_ENTRY` | Duplicate content submission |
| 103 | `ERR_NONEXISTENT_ITEM` | Referenced item does not exist |
| 104 | `ERR_INADEQUATE_BALANCE` | Insufficient STX balance |
| 105 | `ERR_INVALID_TOPIC` | Topic not in approved list |
| 106 | `ERR_INVALID_FLAG` | Invalid flagging attempt |
| 107 | `ERR_OVERFLOW` | Arithmetic overflow detected |
| 108 | `ERR_INVALID_APPRAISAL` | Vote must be -1 or 1 |
| 109 | `ERR_INVALID_ITEM_ID` | Invalid item identifier |

## 🔧 Development

### Code Standards

- Follow Clarity best practices
- Comprehensive error handling
- Detailed inline documentation
- Consistent naming conventions
- Gas-optimized implementations

### Security Considerations

- Integer overflow protection
- Access control enforcement
- Input validation on all functions
- Reentrancy attack prevention
- Economic spam prevention

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Development Guidelines

- Write comprehensive tests for new features
- Follow existing code style and conventions
- Update documentation for API changes
- Ensure all tests pass before submitting
- Add appropriate error handling

## 📄 License

This project is licensed under the ISC License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built on [Stacks](https://stacks.org/) for Bitcoin-grade security
- Uses [Clarity](https://clarity-lang.org/) smart contract language
- Testing framework powered by [Clarinet](https://github.com/hirosystems/clarinet)
