// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title BlueCarbonRegistry
 * @dev ERC1155 contract for Blue Carbon Credits with role-based access control
 *
 * Features:
 * - Mint carbon credits for verified projects
 * - Retire credits (burn) with certificate generation
 * - Project-based token batches
 * - Role-based permissions for minting and administration
 * - Supply tracking and transparency
 */
contract BlueCarbonRegistry is ERC1155, AccessControl, ERC1155Supply, ReentrancyGuard {
    using Strings for uint256;

    // Roles
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Project and credit information
    struct CreditBatch {
        string projectId;           // Off-chain project identifier
        uint256 totalCredits;       // Total credits minted for this batch
        uint256 retiredCredits;     // Total credits retired from this batch
        string projectData;         // IPFS hash or metadata URI
        address projectOwner;       // NGO that owns the project
        uint256 mintTimestamp;      // When credits were minted
        bool active;               // Whether batch is active
    }

    // Retirement record for transparency
    struct Retirement {
        uint256 tokenId;           // Token ID retired
        uint256 amount;            // Amount retired
        address retiree;           // Who retired the credits
        string certificateURI;     // Certificate metadata URI
        uint256 timestamp;         // When retired
        string purpose;            // Retirement purpose/reason
    }

    // State variables
    mapping(uint256 => CreditBatch) public creditBatches;
    mapping(address => Retirement[]) public retirementHistory;
    mapping(uint256 => Retirement[]) public tokenRetirements;

    uint256 public nextTokenId = 1;
    uint256 public totalCreditsMinted;
    uint256 public totalCreditsRetired;

    // Events
    event CreditsMinted(
        uint256 indexed tokenId,
        string projectId,
        address projectOwner,
        uint256 amount,
        string projectData
    );

    event CreditsRetired(
        uint256 indexed tokenId,
        address indexed retiree,
        uint256 amount,
        string certificateURI,
        string purpose
    );

    event ProjectUpdated(
        uint256 indexed tokenId,
        string projectData
    );

    constructor(
        address admin,
        string memory baseURI
    ) ERC1155(baseURI) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);
    }

    /**
     * @dev Mint carbon credits for a verified project
     * @param projectId Off-chain project identifier
     * @param projectOwner NGO address that owns the project
     * @param amount Number of credits to mint
     * @param projectData IPFS hash or metadata URI for project details
     */
    function mintCredits(
        string memory projectId,
        address projectOwner,
        uint256 amount,
        string memory projectData
    ) external onlyRole(MINTER_ROLE) nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(projectOwner != address(0), "Invalid project owner");
        require(bytes(projectId).length > 0, "Project ID required");

        uint256 tokenId = nextTokenId++;

        // Store credit batch information
        creditBatches[tokenId] = CreditBatch({
            projectId: projectId,
            totalCredits: amount,
            retiredCredits: 0,
            projectData: projectData,
            projectOwner: projectOwner,
            mintTimestamp: block.timestamp,
            active: true
        });

        // Mint tokens to project owner
        _mint(projectOwner, tokenId, amount, "");

        totalCreditsMinted += amount;

        emit CreditsMinted(tokenId, projectId, projectOwner, amount, projectData);
    }

    /**
     * @dev Retire (burn) carbon credits and generate retirement certificate
     * @param tokenId Token ID to retire
     * @param amount Amount to retire
     * @param certificateURI URI for retirement certificate
     * @param purpose Purpose of retirement
     */
    function retireCredits(
        uint256 tokenId,
        uint256 amount,
        string memory certificateURI,
        string memory purpose
    ) external nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(balanceOf(msg.sender, tokenId) >= amount, "Insufficient balance");
        require(creditBatches[tokenId].active, "Token batch not active");

        // Burn the tokens
        _burn(msg.sender, tokenId, amount);

        // Update retirement tracking
        creditBatches[tokenId].retiredCredits += amount;
        totalCreditsRetired += amount;

        // Record retirement
        Retirement memory retirement = Retirement({
            tokenId: tokenId,
            amount: amount,
            retiree: msg.sender,
            certificateURI: certificateURI,
            timestamp: block.timestamp,
            purpose: purpose
        });

        retirementHistory[msg.sender].push(retirement);
        tokenRetirements[tokenId].push(retirement);

        emit CreditsRetired(tokenId, msg.sender, amount, certificateURI, purpose);
    }

    /**
     * @dev Update project metadata (admin only)
     * @param tokenId Token ID to update
     * @param projectData New project data URI
     */
    function updateProjectData(
        uint256 tokenId,
        string memory projectData
    ) external onlyRole(ADMIN_ROLE) {
        require(creditBatches[tokenId].totalCredits > 0, "Token does not exist");

        creditBatches[tokenId].projectData = projectData;
        emit ProjectUpdated(tokenId, projectData);
    }

    /**
     * @dev Deactivate a credit batch (admin only)
     * @param tokenId Token ID to deactivate
     */
    function deactivateBatch(uint256 tokenId) external onlyRole(ADMIN_ROLE) {
        require(creditBatches[tokenId].totalCredits > 0, "Token does not exist");
        creditBatches[tokenId].active = false;
    }

    /**
     * @dev Get retirement history for an address
     * @param account Address to query
     * @return Array of retirements
     */
    function getRetirementHistory(address account) external view returns (Retirement[] memory) {
        return retirementHistory[account];
    }

    /**
     * @dev Get retirements for a specific token
     * @param tokenId Token ID to query
     * @return Array of retirements for the token
     */
    function getTokenRetirements(uint256 tokenId) external view returns (Retirement[] memory) {
        return tokenRetirements[tokenId];
    }

    /**
     * @dev Get available (non-retired) credits for a token
     * @param tokenId Token ID to query
     * @return Available credits
     */
    function getAvailableCredits(uint256 tokenId) external view returns (uint256) {
        CreditBatch memory batch = creditBatches[tokenId];
        return batch.totalCredits - batch.retiredCredits;
    }

    /**
     * @dev Get project information for a token
     * @param tokenId Token ID to query
     * @return CreditBatch struct with project details
     */
    function getProjectInfo(uint256 tokenId) external view returns (CreditBatch memory) {
        return creditBatches[tokenId];
    }

    /**
     * @dev Check if token exists
     * @param tokenId Token ID to check
     * @return Whether token exists
     */
    function tokenExists(uint256 tokenId) external view returns (bool) {
        return creditBatches[tokenId].totalCredits > 0;
    }

    /**
     * @dev Override URI to include token-specific metadata
     * @param tokenId Token ID
     * @return Token URI
     */
    function uri(uint256 tokenId) public view override returns (string memory) {
        require(creditBatches[tokenId].totalCredits > 0, "Token does not exist");

        string memory baseURI = super.uri(tokenId);
        return string(abi.encodePacked(baseURI, tokenId.toString()));
    }

    // Required overrides for OpenZeppelin v5.x
    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override(ERC1155, ERC1155Supply) {
        super._update(from, to, ids, values);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}