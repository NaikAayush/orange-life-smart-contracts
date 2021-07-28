const OrangeLife = artifacts.require("OrangeLife")

contract("Test orange life", async accounts => {
    it("should add and get new medical record", async () => {
        const docCID = "QmbWqxBEKC3P8tqsKc98xmWNzrzDtRLMiMPL8wBuTGsMnR";
        const orange = await OrangeLife.deployed();
        await orange.addMedicalRecord(docCID, 1, {"from": accounts[0]});

        const res1 = await orange.getMedicalRecords(accounts[0]);
        assert.equal(res1.length, 1);
        assert.equal(res1[0].docCID, docCID);
        assert.equal(res1[0].nonce, 1);
        assert.equal(res1[0].hasAccess[0], accounts[0]);
    });

    it("should add and get particular medical record", async () => {
        const docCID = "QmbWqxBEKC3P8tqsKc98xmWNzrzDtRLMiMPL8wBuTGsMnS";
        const orange = await OrangeLife.deployed();
        await orange.addMedicalRecord(docCID, 100, {"from": accounts[0]});

        const res1 = await orange.getMedicalRecord(accounts[0], 1);;
        assert.equal(res1.docCID, docCID);
        assert.equal(res1.nonce, 100);
        assert.equal(res1.hasAccess[0], accounts[0]);
    });

    it("should request access", async () => {
        const orange = await OrangeLife.deployed();
        await orange.requestAccess(accounts[0], 0, {"from": accounts[1]});

        const res1 = await orange.getMedicalRecord(accounts[0], 0);
        assert.equal(res1.accessRequested[0], accounts[1]);
    });

    it("should grant access", async () => {
        const orange = await OrangeLife.deployed();
        await orange.grantAccess(accounts[1], 0, {"from": accounts[0]});

        const res1 = await orange.getMedicalRecord(accounts[0], 0);
        assert.equal(res1.hasAccess.length, 2)
        assert.equal(res1.hasAccess[1], accounts[1]);
    });

    it("should revoke access", async () => {
        const orange = await OrangeLife.deployed();
        await orange.revokeAccess(accounts[1], 0, {"from": accounts[0]});

        const res1 = await orange.getMedicalRecord(accounts[0], 0);
        assert.equal(res1.hasAccess.length, 1);
        assert.equal(res1.hasAccess[0], accounts[0]);
    })
});