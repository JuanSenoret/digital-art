// This script is designed to test the solidity smart contract - SuppyChain.sol -- and the various functions within
// Declare a variable and assign the compiled smart contract artifact
const SmartPic = artifacts.require('SmartPic');
const Web3 = require('web3');
const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:7545"));

contract('SmartPic', accounts => {
    const ownerID = accounts[0];
    const newOwnerID = accounts[1];
    const fakeOwnerID = accounts[2];
    const user1 = accounts[3];
    const user2 = accounts[4];
    const emptyAddress = 0;
    const ipfsHashId = "QmXpUiBFn7BKbxGW8so4TvrJUdjorNhBzNj4JrdELWwuEL";
    const picDescription = "Picture taken at Miami beach";
    let tx;

    console.log("ganache accounts used here...");
    console.log("Contract Owner: accounts[0] ", accounts[0]);

    describe('Check ownable functions', () => {
        beforeEach(async () => { 
            this.contract = await SmartPic.new({from: accounts[0]});
        });

        it('Contract Owner is correct', async () => {
            assert.equal(await this.contract.isOwner({from: ownerID}), true);
        });

        it('Contract Owner is not correct', async () => {
            assert.equal(await this.contract.isOwner({from: fakeOwnerID}), false);
        });

        it('Only contract owner can transfer ownership', async () => {
            // fakeOwnerID try to transfer the ownership to newOwnerID but it is no possible
            await expectThrow(this.contract.transferOwnership(newOwnerID, {from: fakeOwnerID})); 
        });

        it('Contract owner transfers ownership new owner account', async () => {
            // ownerID transfer the ownership to newOwnerID
            tx = await this.contract.transferOwnership(newOwnerID, {from: ownerID});

            assert.equal(tx.logs[0].event, 'TransferOwnership');
            assert.equal(tx.logs[0].args.oldOwner, ownerID);
            assert.equal(tx.logs[0].args.newOwner, newOwnerID);
            assert.equal(await this.contract.isOwner({from: newOwnerID}), true);
        });

        it('Renunce contract ownership', async () => {
            tx = await this.contract.renounceOwnership({from: ownerID});
            assert.equal(tx.logs[0].event, 'TransferOwnership');
            assert.equal(tx.logs[0].args.oldOwner, ownerID);
            assert.equal(tx.logs[0].args.newOwner, emptyAddress);
        });
    });

    describe('Testing SmartPic smart contract functions to check the workflow', () => {
        before(async () => { 
            this.contract = await SmartPic.new({from: accounts[0]});
        });

        it('Check user has been added to the smart contract', async () => {
            // Add aluminum producer to the struct
            tx = await this.contract.addUser(user1, {from: ownerID});

            assert.equal(tx.logs[0].event, 'UserAdded');
            assert.equal(tx.logs[0].args.account, user1);
        });

        it('Call function uploadPicturetoIpfs() that allows a user to upload a picture to IPFS network', async () => {
            tx = await this.contract.uploadPicturetoIpfs(
                ipfsHashId,
                user1,
                picDescription,
                {from: user1}
            );

            assert.equal(tx.logs[0].event, 'Uploaded');
            assert.equal(tx.logs[0].args.ipfsHashId, ipfsHashId);
            assert.equal(tx.logs[0].args.emiter, user1);
        });

        it('Call function uploadPicturetoIpfs() and check that user can not store again the same picture', async () => {
            await expectThrow(this.contract.uploadPicturetoIpfs(ipfsHashId, user1, picDescription, {from: user2}));
        });

        it('Call function fetchPictureBufferPublic() and check the picture data', async () => {
            // Fetch the data for the added dan previuosly
            const resultBufferPublic = await this.contract.fetchPictureBufferPublic.call(ipfsHashId);

            // Verify the result set
            assert.equal(resultBufferPublic[0], ipfsHashId, 'Error: Invalid picture IPFS hash');
            assert.equal(resultBufferPublic[1], user1, 'Error: Invalid owner Id');
            assert.equal(resultBufferPublic[2], picDescription, 'Error: Invalid picture description');
            assert.equal(resultBufferPublic[4], 0, 'Error: Invalid picture state');
        });
    });

});

const expectThrow = async (promise) => {
    try {
        await promise;
    } catch (error) {
        assert.exists(error);
        return;
    }

    assert.fail('Expected an error but didnt see one!');
};