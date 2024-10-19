# ChainSource: Blockchain Supply Chain Transparency

## Overview
ChainSource is a blockchain-based solution for supply chain transparency built on Stacks blockchain using Clarity smart contracts. It enables real-time tracking of products from origin to destination.

## Features
- Product registration with unique IDs
- Location tracking
- Manufacturer verification
- Origin certification
- Immutable history

## Smart Contract Functions

### add-product
```clarity
(add-product name origin location)
```
Registers new product with name, origin, and current location.

### update-location
```clarity
(update-location product-id new-location)
```
Updates product location.

### get-product
```clarity
(get-product product-id)
```
Retrieves product details.

## Setup
1. Install Clarinet
2. Clone repository
3. Deploy: `clarinet deploy`

## Testing
```bash
clarinet test
```
