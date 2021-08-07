// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

// enable support to return a dynamic array (MedicalRecord[] in our case)
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/GSN/GSNRecipient.sol";

contract OrangeLife is GSNRecipient {
  struct MedicalRecord {
    string docCID;
    string verifyingKey;
    string publicKey;
    uint32 nonce;
    address[] hasAccess;
    address[] accessRequested;
  }

  // global storage for all medical records
  mapping (address => MedicalRecord[]) medicalRecords;
  address owner;

  // events
  event NewMedicalRecord(address owner, uint idx, string docCID, string verifyingKey, string publicKey, uint32 nonce);
  // event AccessedAllMedicalRecords(address accessor, address owner);
  // event AccessedMedicalRecord(address accessor, address owner, uint idx);
  event RequestedAccess(address requestor, address owner, uint idx, string docCID);
  event GrantedAccess(address requestor, address owner, uint idx, string docCID);
  event RevokedAccess(address requestor, address owner, uint idx, string docCID);

  // TODO: errors are not supported in 0.5.16
  // errors
  // error DoesNotHaveAccess(address requestor, address owner, uint idx);

  constructor() {
    owner = _msgSender();
  }

  modifier _ownerOnly() {
    require(_msgSender() == owner);
    _;
  }

  // helper to remove address at index in an address array
  function deleteAddressAtIndex(address[] storage arr, uint idx) private {
    require(idx < arr.length);
    arr[idx] = arr[arr.length - 1];
    arr.pop();
  }

  function addMedicalRecord(string memory docCID, string memory verifyingKey, string memory publicKey, uint32 nonce) public {
    address sender = _msgSender();
    // uint idx = medicalRecords[sender].length;
    // medicalRecords[sender].push();
    // MedicalRecord storage record = medicalRecords[sender][idx];
    // record.docCID = docCID;
    // record.nonce = nonce;
    // record.hasAccess = [sender];
    address[] memory hasAccess = new address[](1);
    hasAccess[0] = sender;
    address[] memory accessRequested = new address[](0);
    medicalRecords[sender].push(MedicalRecord({
      docCID: docCID,
      nonce: nonce,
      hasAccess: hasAccess,
      accessRequested: accessRequested,
      verifyingKey: verifyingKey,
      publicKey: publicKey
    }));

    emit NewMedicalRecord(sender, medicalRecords[sender].length-1, docCID, verifyingKey, publicKey, nonce);
  }

  function getMedicalRecords(address sender) public view returns (MedicalRecord[] memory records) {
    // emit AccessedAllMedicalRecords(_msgSender(), sender);

    return medicalRecords[sender];
  }

  function getMedicalRecord(address sender, uint idx) public view returns (MedicalRecord memory record) {
    require(idx < medicalRecords[sender].length);

    // emit AccessedMedicalRecord(_msgSender(), sender, idx);

    return medicalRecords[sender][idx];
  }

  // idx is index of medical record in the array (specific to each address)
  function requestAccess(address sender, uint idx) public {
    require(idx < medicalRecords[sender].length);

    emit RequestedAccess(_msgSender(), sender, idx, medicalRecords[sender][idx].docCID);

    medicalRecords[sender][idx].accessRequested.push(_msgSender());
  }

  function grantAccess(address addrToGrant, uint idx) public {
    require(idx < medicalRecords[_msgSender()].length);

    emit GrantedAccess(_msgSender(), addrToGrant, idx, medicalRecords[_msgSender()][idx].docCID);

    medicalRecords[_msgSender()][idx].hasAccess.push(addrToGrant);
  }

  function revokeAccess(address addrToRevoke, uint idx) public {
    require(idx < medicalRecords[_msgSender()].length);

    uint searchIdx = 0;
    while (searchIdx < medicalRecords[_msgSender()][idx].hasAccess.length) {
      if (medicalRecords[_msgSender()][idx].hasAccess[searchIdx] == addrToRevoke) {
        break;
      }
      searchIdx++;
    }

    if (searchIdx == medicalRecords[_msgSender()][idx].hasAccess.length) {
      revert(); // DoesNotHaveAccess({requestor: addrToRevoke, sender: _msgSender(), idx: idx});
    }

    emit RevokedAccess(_msgSender(), addrToRevoke, idx, medicalRecords[_msgSender()][idx].docCID);

    deleteAddressAtIndex(medicalRecords[_msgSender()][idx].hasAccess, searchIdx);
  }

  function acceptRelayedCall(
      address relay,
      address from,
      bytes calldata encodedFunction,
      uint256 transactionFee,
      uint256 gasPrice,
      uint256 gasLimit,
      uint256 nonce,
      bytes calldata approvalData,
      uint256 maxPossibleCharge
  ) external override pure returns (uint256, bytes memory) {
      // TODO: control which calls to relay
      // reference: https://docs.openzeppelin.com/contracts/3.x/gsn-strategies
      return _approveRelayedCall();
  }

  // We won't do any pre or post processing, so leave _preRelayedCall and _postRelayedCall empty
  function _preRelayedCall(bytes memory context) internal override returns (bytes32) {
  }

  function _postRelayedCall(bytes memory context, bool, uint256 actualCharge, bytes32) internal override {
  }
}