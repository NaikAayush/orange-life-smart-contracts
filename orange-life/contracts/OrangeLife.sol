// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

// enable support to return a dynamic array (MedicalRecord[] in our case)
pragma experimental ABIEncoderV2;

import "@opengsn/contracts/src/BaseRelayRecipient.sol";

contract OrangeLife is BaseRelayRecipient {
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
  event RequestedAccess(address requestor, address owner, uint idx);
  event GrantedAccess(address requestor, address owner, uint idx);
  event RevokedAccess(address requestor, address owner, uint idx);

  // TODO: errors are not supported in 0.5.16
  // errors
  // error DoesNotHaveAccess(address requestor, address owner, uint idx);

  constructor(address _trustedForwarder) {
    trustedForwarder = _trustedForwarder;
    owner = _msgSender();
  }

  modifier _ownerOnly() {
    require(_msgSender() == owner);
    _;
  }

  function setTrustedForwarder(address _trustedForwarder) public _ownerOnly {
    trustedForwarder = _trustedForwarder;
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

    emit RequestedAccess(_msgSender(), sender, idx);

    medicalRecords[sender][idx].accessRequested.push(_msgSender());
  }

  function grantAccess(address addrToGrant, uint idx) public {
    require(idx < medicalRecords[_msgSender()].length);

    emit GrantedAccess(_msgSender(), addrToGrant, idx);

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

    emit RevokedAccess(_msgSender(), addrToRevoke, idx);

    deleteAddressAtIndex(medicalRecords[_msgSender()][idx].hasAccess, searchIdx);
  }
  
  /** 
    * Override this function.
    * This version is to keep track of BaseRelayRecipient you are using
    * in your contract. 
    */
  function versionRecipient() external pure override returns (string memory) {
      return "1";
  }
}