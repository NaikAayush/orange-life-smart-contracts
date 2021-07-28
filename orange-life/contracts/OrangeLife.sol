// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

// enable support to return a dynamic array (MedicalRecord[] in our case)
pragma experimental ABIEncoderV2;

contract OrangeLife {
  struct MedicalRecord {
    string docCID;
    uint32 nonce;
    address[] hasAccess;
    address[] accessRequested;
  }

  mapping (address => MedicalRecord[]) medicalRecords;

  constructor() public {
  }

  // helper to remove address at index in an address array
  function deleteAddressAtIndex(address[] storage arr, uint idx) private {
    require(idx < arr.length);
    arr[idx] = arr[arr.length - 1];
    arr.pop();
  }

  function addMedicalRecord(string memory docCID, uint32 nonce) public {
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
    medicalRecords[owner].push(MedicalRecord({docCID: docCID, nonce: nonce, hasAccess: hasAccess, accessRequested: accessRequested}));
  }

  function getMedicalRecords(address owner) public view returns (MedicalRecord[] memory records) {
    // TODO: add event here

    return medicalRecords[owner];
  }

  function getMedicalRecord(address owner, uint idx) public view returns (MedicalRecord memory record) {
    // TODO: add event here

    return medicalRecords[owner][idx];
  }

  // idx is index of medical record in the array (specific to each address)
  function requestAccess(address owner, uint idx) public {
    require(idx < medicalRecords[owner].length);

    // TODO: add event here

    medicalRecords[owner][idx].accessRequested.push(msg.sender);
  }

  function grantAccess(address addrToGrant, uint idx) public {
    require(idx < medicalRecords[msg.sender].length);

    // TODO: add event here

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
      // TODO: add error here
      revert();
    }

    deleteAddressAtIndex(medicalRecords[msg.sender][idx].hasAccess, searchIdx);
  }
}