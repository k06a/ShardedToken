const { expectRevert } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

const ShardedToken = artifacts.require('ShardedToken');
const ShardedTokenExtension = artifacts.require('ShardedTokenExtension');

async function extractEventExtensionInstalled (txReceipt) {
    const records = txReceipt.logs.filter(record => record.event === 'ExtensionInstalled');
    expect(records.length).to.be.equal(1);
    return ShardedTokenExtension.at(records[0].args.extension);
}

// https://solidity.readthedocs.io/en/v0.4.24/metadata.html#encoding-of-the-metadata-hash-in-the-bytecode
function trimBytecode (bytecode) {
    return bytecode.substr(0, bytecode.length - 34 * 2);
}

contract('ShardedToken', function ([_, w1, w2, w3]) {
    describe('ShardedToken', async function () {
        beforeEach(async function () {
            this.token = await ShardedToken.new();
        });

        it('Should contain right extension bytecode', async function () {
            const ext = await ShardedTokenExtension.new();

            // If this check fails copy new bytecode to ShardedToken constructor
            if (trimBytecode(await this.token.extensionBytecode()) !== trimBytecode(ext.constructor._json.bytecode)) {
                expect(ext.constructor._json.bytecode).false;
            }
        });

        it('Should deploy extension for user', async function () {
            const txReceipt = await this.token.installExtension({ from: w1 });
            const ext = await extractEventExtensionInstalled(txReceipt);

            expect(await ext.base()).to.be.equal(this.token.address);
            expect(await ext.thisExtensionHash()).to.be.equal(await this.token.extensionBytecodeHash());
        });

        it('Should not redeploy extension for user', async function () {
            await this.token.installExtension({ from: w1 });

            await expectRevert.unspecified(
                this.token.installExtension({ from: w1 })
            );
        });

        describe('Mint', async function () {
            it('Should deny mint to non-owner', async function () {
                await expectRevert.unspecified(
                    this.token.mint(w1, 1000, { from: w1 })
                );
            });

            it('Should deny mint for user without ext', async function () {
                await expectRevert.unspecified(
                    this.token.mint(w1, 1000)
                );
            });

            it('Should allow mint', async function () {
                const txReceipt = await this.token.installExtension({ from: w1 });
                const ext = await extractEventExtensionInstalled(txReceipt);

                await this.token.mint(w1, 1000);

                expect(await ext.balance()).to.be.bignumber.equal('1000');
            });
        });

        describe('Burn', async function () {
            it('Should deny burn by non-owner', async function () {
                const txReceipt = await this.token.installExtension({ from: w1 });
                const ext = await extractEventExtensionInstalled(txReceipt);

                await this.token.mint(w1, 1000);
                await expectRevert.unspecified(
                    ext.burn(1000, { from: w2 })
                );
            });

            it('Should deny burn by non-owner even admin', async function () {
                const txReceipt = await this.token.installExtension({ from: w1 });
                const ext = await extractEventExtensionInstalled(txReceipt);

                await this.token.mint(w1, 1000);
                await expectRevert.unspecified(
                    ext.burn(1000, { from: _ })
                );
            });

            it('Should allow burn', async function () {
                const txReceipt = await this.token.installExtension({ from: w1 });
                const ext = await extractEventExtensionInstalled(txReceipt);

                await this.token.mint(w1, 1000);
                await ext.burn(1000, { from: w1 });

                expect(await ext.balance()).to.be.bignumber.equal('0');
            });
        });

        describe('Transfer', async function () {
            it('Should deny transfer to user without ext', async function () {
                const txReceipt = await this.token.installExtension({ from: w1 });
                const ext = await extractEventExtensionInstalled(txReceipt);

                await this.token.mint(w1, 1000);
                await expectRevert.unspecified(
                    ext.transfer(w2, 100, { from: w1 })
                );
            });

            it('Should allow transfer', async function () {
                const txReceipt1 = await this.token.installExtension({ from: w1 });
                const ext1 = await extractEventExtensionInstalled(txReceipt1);

                const txReceipt2 = await this.token.installExtension({ from: w2 });
                const ext2 = await extractEventExtensionInstalled(txReceipt2);

                await this.token.mint(w1, 1000);
                await ext1.transfer(w2, 100, { from: w1 });

                expect(await ext1.balance()).to.be.bignumber.equal('900');
                expect(await ext2.balance()).to.be.bignumber.equal('100');
            });

            it('Should deny transferring more than balance', async function () {
                const txReceipt1 = await this.token.installExtension({ from: w1 });
                const ext1 = await extractEventExtensionInstalled(txReceipt1);

                await this.token.installExtension({ from: w2 });

                await this.token.mint(w1, 1000);
                await expectRevert.unspecified(
                    ext1.transfer(w2, 1100, { from: w1 })
                );
            });
        });
    });
});
