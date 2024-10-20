// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

struct DealProposalToValidate {
    // todo ajouter date de fin de la vente
    string goodsDescription;
    uint256 individualFeeInUsd;
    uint256 requiredNbOfCustomers;
    string imageUrl;
    uint256 internalId;
}

struct DeployedDeal {
    // todo ajouter date de fin de la vente
    string goodsDescription;
    uint256 individualFeeInWei;
    uint256 requiredNbOfCustomers;
    address seller;
    string imageUrl;
    uint256 internalId;
}

struct DeployedMinimal {
    address deployed;
    uint256 internalId;
}
