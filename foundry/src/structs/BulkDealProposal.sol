// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

struct BulkDealProposal {
    // todo ajouter date de fin de la vente
    string goodsDescription;
    uint256 individualFeeInEur;
    uint256 requiredNbOfCustomers;
    address seller;
    bool wasPublished;
}
