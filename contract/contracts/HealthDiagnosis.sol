// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title HealthDiagnosis
 * @author MDiagnotix AI
 * @notice Fully onchain health diagnostics dApp.
 *         Stores symptoms, AI diagnosis, timestamp, and payment.
 *         Fee is set on-chain and updatable by owner.
 *         Optimized for gas efficiency on Hyperion.
 */
contract HealthDiagnosis {
    // ============ DATA STRUCTURE ============

    /**
     * @notice Compact record of a diagnostic session
     * @param symptoms Symptom string (e.g., "fever,cough")
     * @param diagnosis AI-generated suggestion
     * @param timestamp Unix timestamp
     * @param payment Amount paid in wei
     */
    struct Record {
        string symptoms;
        string diagnosis;
        uint64 timestamp;
        uint128 payment;
    }

    // ============ STATE VARIABLES ============

    /// @notice Mapping from user address to their diagnosis records
    mapping(address => Record[]) public userRecords;

    /// @notice Global record counter
    uint256 public recordCount;

    /// @notice Address of contract owner (set once on deployment)
    address public immutable owner;

    /// @notice Fee required to submit a diagnosis (default: 0.01 ETH)
    uint256 public fee = 0.001 ether; // Default fee: 10^16 wei (0.01 ETH)

    // ============ EVENTS ============

    /**
     * @notice Emitted when a new diagnosis is recorded
     * @param user Address of the patient
     * @param symptoms Submitted symptom string
     * @param diagnosis AI-generated result
     * @param timestamp Unix timestamp
     */
    event Diagnosed(
        address indexed user,
        string symptoms,
        string diagnosis,
        uint256 timestamp
    );

    /**
     * @notice Emitted when owner updates the fee
     * @param oldFee Previous fee in wei
     * @param newFee New fee in wei
     */
    event FeeUpdated(uint256 oldFee, uint256 newFee);

    // ============ MODIFIERS ============

    /// @notice Only owner can call restricted functions
    modifier onlyOwner() {
        require(msg.sender == owner, "HealthDiagnosis: not owner");
        _;
    }

    // ============ CONSTRUCTOR ============

    /**
     * @notice Initializes contract and sets owner
     * @dev No parameters. Default fee is 0.01 ether.
     */
    constructor() {
        owner = msg.sender;
    }

    // ============ CORE FUNCTION ============

    /**
     * @notice Submit a new diagnosis with symptoms and AI result
     * @dev User must pay at least `fee`. Data stored fully onchain.
     * @param _symptoms Symptom string (e.g., "fever,cough")
     * @param _diagnosis AI-generated diagnostic suggestion
     */
    function submitDiagnosis(
        string calldata _symptoms,
        string calldata _diagnosis
    ) external payable {
        require(msg.value >= fee, "HealthDiagnosis: insufficient payment");

        userRecords[msg.sender].push(
            Record({
                symptoms: _symptoms,
                diagnosis: _diagnosis,
                timestamp: uint64(block.timestamp),
                payment: uint128(msg.value)
            })
        );

        unchecked {
            recordCount++;
        }

        emit Diagnosed(msg.sender, _symptoms, _diagnosis, block.timestamp);
    }

    // ============ OWNER-ONLY FUNCTION ============

    /**
     * @notice Update the submission fee (owner only)
     * @dev Use carefully — affects all future submissions
     * @param _newFee New fee in wei (e.g., 0.02 ether)
     */
    function setFee(uint256 _newFee) external onlyOwner {
        uint256 oldFee = fee;
        fee = _newFee;
        emit FeeUpdated(oldFee, _newFee);
    }

    // ============ READ FUNCTIONS ============

    /**
     * @notice Get number of records for a user
     * @param user Wallet address
     * @return Count of diagnosis records
     */
    function getRecordCount(address user) external view returns (uint256) {
        return userRecords[user].length;
    }

    /**
     * @notice Get all diagnosis records for a user
     * @param user Wallet address
     * @return Array of Records
     */
    function getRecords(address user) external view returns (Record[] memory) {
        return userRecords[user];
    }

    // ============ WITHDRAW FUNCTION ============

    /**
     * @notice Withdraw collected fees to owner
     * @dev Reverts if no balance
     */
    function withdraw() external onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "HealthDiagnosis: no balance to withdraw");
        (bool sent, ) = owner.call{value: amount}("");
        require(sent, "HealthDiagnosis: failed to send ETH");
    }
}