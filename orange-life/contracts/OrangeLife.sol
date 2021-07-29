// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

// enable support to return a dynamic array (MedicalRecord[] in our case)
pragma experimental ABIEncoderV2;

contract OrangeLife {
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

  // events
  event NewMedicalRecord(address owner, uint idx);
  // event AccessedAllMedicalRecords(address accessor, address owner);
  // event AccessedMedicalRecord(address accessor, address owner, uint idx);
  event RequestedAccess(address requestor, address owner, uint idx);
  event GrantedAccess(address requestor, address owner, uint idx);
  event RevokedAccess(address requestor, address owner, uint idx);

  // TODO: errors are not supported in 0.5.16
  // errors
  // error DoesNotHaveAccess(address requestor, address owner, uint idx);

  constructor() public {
  }

  // helper to remove address at index in an address array
  function deleteAddressAtIndex(address[] storage arr, uint idx) private {
    require(idx < arr.length);
    arr[idx] = arr[arr.length - 1];
    arr.pop();
  }

  function addMedicalRecord(string memory docCID, string memory verifyingKey, string memory publicKey, uint32 nonce) public {
    address owner = msg.sender;
    // uint idx = medicalRecords[owner].length;
    // medicalRecords[owner].push();
    // MedicalRecord storage record = medicalRecords[owner][idx];
    // record.docCID = docCID;
    // record.nonce = nonce;
    // record.hasAccess = [owner];
    address[] memory hasAccess = new address[](1);
    hasAccess[0] = owner;
    address[] memory accessRequested = new address[](0);
    medicalRecords[owner].push(MedicalRecord({
      docCID: docCID,
      nonce: nonce,
      hasAccess: hasAccess,
      accessRequested: accessRequested,
      verifyingKey: verifyingKey,
      publicKey: publicKey
    }));

    emit NewMedicalRecord(owner, medicalRecords[owner].length-1);
  }

  function getMedicalRecords(address owner) public view returns (MedicalRecord[] memory records) {
    // emit AccessedAllMedicalRecords(msg.sender, owner);

    return medicalRecords[owner];
  }

  function getMedicalRecord(address owner, uint idx) public view returns (MedicalRecord memory record) {
    require(idx < medicalRecords[owner].length);

    // emit AccessedMedicalRecord(msg.sender, owner, idx);

    return medicalRecords[owner][idx];
  }

  // idx is index of medical record in the array (specific to each address)
  function requestAccess(address owner, uint idx) public {
    require(idx < medicalRecords[owner].length);

    emit RequestedAccess(msg.sender, owner, idx);

    medicalRecords[owner][idx].accessRequested.push(msg.sender);
  }

  function grantAccess(address addrToGrant, uint idx) public {
    require(idx < medicalRecords[msg.sender].length);

    emit GrantedAccess(msg.sender, addrToGrant, idx);

    medicalRecords[msg.sender][idx].hasAccess.push(addrToGrant);
  }

  function revokeAccess(address addrToRevoke, uint idx) public {
    require(idx < medicalRecords[msg.sender].length);

    uint searchIdx = 0;
    while (searchIdx < medicalRecords[msg.sender][idx].hasAccess.length) {
      if (medicalRecords[msg.sender][idx].hasAccess[searchIdx] == addrToRevoke) {
        break;
      }
      searchIdx++;
    }

    if (searchIdx == medicalRecords[msg.sender][idx].hasAccess.length) {
      revert(); // DoesNotHaveAccess({requestor: addrToRevoke, owner: msg.sender, idx: idx});
    }

    emit RevokedAccess(msg.sender, addrToRevoke, idx);

    deleteAddressAtIndex(medicalRecords[msg.sender][idx].hasAccess, searchIdx);
  }
}