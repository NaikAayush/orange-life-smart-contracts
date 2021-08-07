// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

// enable support to return a dynamic array (MedicalRecord[] in our case)
pragma experimental ABIEncoderV2;

import "@opengsn/contracts/src/BaseRelayRecipient.sol";
// import "@opengsn/contracts/src/interfaces/IKnowForwarderAddress.sol";


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
  
  address public deployer;
  string private _str;
  address private _strOwner;

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

    constructor(address forwarder) {
        trustedForwarder = forwarder;

        deployer = msg.sender;

        // initializing it with this
        _str = "init";
        _strOwner = msg.sender;
    }

  modifier _ownerOnly() {
    require(_msgSender() == _strOwner);
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


  // event to be emitted for denoting string got updated
  event StringUpdated(string _prev, address _preOwner, string _current, address _currentOwner);

  function getTrustedForwarder() public view returns(address) {
      return trustedForwarder;
  }

  function setTrustedForwarder(address forwarder) public {
      require(_msgSender() == deployer, "Only deployer can update it");

      trustedForwarder = forwarder;
  }

  // get current string
  function getString() public view returns(string memory) {
      return _str;
  }

  // get current string owner
  function getStringOwner() public view returns(address) {
      return _strOwner;
  }

  // updates string content & also owner address
  // with the address which invoked this function
  function update(string memory _string) external _ownerOnly {
      string memory _tmpStr = _str;
      address _tmpStrOwner = _strOwner;

      _str = _string;
      _strOwner = _msgSender();

      emit StringUpdated(_tmpStr, _tmpStrOwner, _str, _strOwner);
  }

  function versionRecipient() external virtual view override returns (string memory) {
      return "1.0";
  }
}