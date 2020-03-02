// const { expectRevert } = require('openzeppelin-test-helpers');
// const { expect } = require('chai');

const ShardedToken = artifacts.require('ShardedToken');

contract('ShardedToken', function ([_, addr1]) {
    describe('ShardedToken', async function () {
        it('should be ok', async function () {
            this.token = await ShardedToken.new();
        });
    });
});
