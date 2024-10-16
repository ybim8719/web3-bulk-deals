// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

struct DealProposalToValidate {
    // todo ajouter date de fin de la vente
    string goodsDescription;
    uint256 individualFeeInEur;
    uint256 requiredNbOfCustomers;
    string imageUrl;
    uint256 internalId;
}

struct DealProposalDeployed {
    // todo ajouter date de fin de la vente
    string goodsDescription;
    uint256 individualFeeInEth;
    uint256 requiredNbOfCustomers;
    address seller;
    string imageUrl;
    uint256 internalId;
}
