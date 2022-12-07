//SPDX-License-Identifier: MIT
// @title    Balls of Art
// @version  1.0.0
// @author   Radek Sienkiewicz | velvetshark.com
pragma solidity 0.8.17;

// Deployed to: 0xC6EA7EDeC54BEf4B53968C2162d141Fa4FA79594

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract Shade is ERC721, Ownable {
    // Structs
    struct Rectangle {
        uint x; // x coordinates of the top left corner
        uint y; // y coordinates of the top left corner
        uint width;
        uint height;
        string border; // ball color
        uint randomSeed;
    }

    // Constants, public variables
    uint constant maxSupply = 111; // max number of tokens
    uint public totalSupply = 0; // number of tokens minted
    uint public mintPrice = 0.0000001 ether;

    // Mapping to store SVG code for each token
    mapping(uint => string) private tokenIdToSvg;

    // Events
    event ShadeCreated(uint indexed tokenId);

    constructor() ERC721("Shade", "SHADE") {}

    // Functions

    // Return a random background color
    function backgroundColors(uint index)
        internal
        pure
        returns (string memory)
    {
        string[3] memory bgColors = [
            "#000000",
            "#FFFFFF",
            "#808080"
        ];
        return bgColors[index];
    }

    // Return a random ball color
    function RectangleColors(uint index) internal pure returns (string memory) {
        string[10] memory bColors = [
            "#2F2F2F",
            "#505050",
            "#777777",
            "#A8A8A8",
            "#333333",
            "#5C5C5C",
            "#CFCFCF",
            "#AFAFAF",
            "#1F1F1F",
            "#B7B7B7"

        ];
        return bColors[index];
    }

    // Create an instance of a Ball
    function createRectangleStruct(
        uint x,
        uint y,
        uint width,
        uint height,
        uint randomSeed
    ) internal pure returns (Rectangle memory) {
        return
            Rectangle({
                x: x,
                y: y,
                width: width,
                height: height,
                border: RectangleColors(randomSeed % 4), // Choose random color from bColors array
                randomSeed: randomSeed
            });
    }

    // Randomly picka a ball size: 1, 2, or 3x
    function drawRectangleSize(uint maxSize, uint randomSeed)
        public
        pure
        returns (uint size)
    {
        // Random number 1-100
        uint r = (randomSeed % 100) + 1;

        // Probabilities:
        // 3x: 20%
        // 2x: 25%
        // else: 1x
        if (maxSize == 3) {
            if (r <= 20) {
                return 3;
            } else if (r <= 45) {
                return 2;
            } else {
                return 1;
            }
        } else {
            // Probabilities:
            // 2x: 30%
            // else: 1x
            if (r <= 30) {
                return 2;
            } else {
                return 1;
            }
        }
    }

function RectangleSvg(Rectangle memory rectangle) public pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<rect x="',
                    uint2str(rectangle.x),
                    '" y="',
                    uint2str(rectangle.y),
                    '" width="',
                    uint2str(rectangle.width),
                    '" height="',
                    uint2str(rectangle.height),
                    '" fill="',
                    rectangle.border,
                    '" /> <path fill="none" stroke="#ffffff" stroke-width="6"  d="M ',
                    uint2str(rectangle.x + rectangle.width - 150),
                    " ",
                    uint2str(rectangle.y + rectangle.height - 50),
                    " L ",
                    uint2str(rectangle.x + rectangle.width - 50),
                    " ",
                    uint2str(rectangle.y + rectangle.height - 50),
                    " L ",
                    uint2str(rectangle.x + rectangle.width - 50),
                    " ",
                    uint2str(rectangle.y + rectangle.height - 150),
                    " L ",
                    uint2str(rectangle.x + rectangle.width - 150),
                    '" />'
                )
            );
    }

    // SVG code for a single line
    function generateLineSvg(uint lineNumber, uint randomSeed)
        public
        pure
        returns (string memory)
    {
        // Line SVG
        string memory lineSvg = "";

        uint y = 150; // Default y for row 1
        if (lineNumber == 2) {
            y = 475; // Default y for row 2
        } else if (lineNumber == 3) {
            y = 800; // Default y for row 3
        }

        // Size of ball at slot 1
        uint rectangleSize1 = drawRectangleSize(3, randomSeed);
        // console.log("Ball size 1: ", ballSize1);

        // Ball size 1x? Paint 1x at slot 1
        if (rectangleSize1 == 1) {
            Rectangle memory rectangle1 = createRectangleStruct(150, y, 300, 300, randomSeed);
            lineSvg = string.concat(lineSvg, RectangleSvg(rectangle1));

            // Slot 2
            // Size of ball at slot 2
            uint rectangleSize2 = drawRectangleSize(2, randomSeed >> 1);
            // console.log("Ball size 2: ", ballSize2);

            // Ball size 1x? Paint 1x at slot 2 and 1x at slot 3
            if (rectangleSize2 == 1) {
                Rectangle memory rectangle2 = createRectangleStruct(
                    475,
                    y,
                    300,
                    300,
                    randomSeed >> 2
                );
                Rectangle memory rectangle3 = createRectangleStruct(
                    800,
                    y,
                    300,
                    300,
                    randomSeed >> 3
                );
                lineSvg = string.concat(
                    lineSvg,
                    RectangleSvg(rectangle2),
                    RectangleSvg(rectangle3)
                );

                // Ball size 2x? Paint 2x at slot 2
            } else if (rectangleSize2 == 2) {
                Rectangle memory rectangle2 = createRectangleStruct(
                    475,
                    y,
                    625,
                    300,
                    randomSeed >> 4
                );
                lineSvg = string.concat(lineSvg, RectangleSvg(rectangle2));
            }

            // Ball size 2x? Paint 2x at slot 1 and 1x at slot 3
        } else if (rectangleSize1 == 2) {
            Rectangle memory rectangle1 = createRectangleStruct(
                150,
                y,
                625,
                300,
                randomSeed >> 5
            );
            Rectangle memory rectangle3 = createRectangleStruct(
                800,
                y,
                300,
                300,
                randomSeed >> 6
            );
            lineSvg = string.concat(lineSvg, RectangleSvg(rectangle1), RectangleSvg(rectangle3));

            // Ball size 3x? Paint 3x at slot 1
        } else if (rectangleSize1 == 3) {
            Rectangle memory rectangle1 = createRectangleStruct(
                150,
                y,
                950,
                300,
                randomSeed >> 7
            );
            lineSvg = string.concat(lineSvg, RectangleSvg(rectangle1));
        }

        return lineSvg;
    }

       function drawCircle(uint circleLocation) internal pure returns (string memory) {
        // Bottom-right location by default
        uint x = 980;
        uint y = 980;

          if (circleLocation == 1) {
            x = 300;
            y = 300;
       } else if (circleLocation == 2) {
            x = 605;
            y = 605;
        } // Location 3 skipped because it's set up as default already, and only changed if location is 1 or 2

        return
            string(
                abi.encodePacked(
                    '<circle cx="',
                    uint2str(x),
                    '" cy="',
                    uint2str(y),
                    '" r="40" fill="#ffffff"><animate attributeType="XML" attributeName="fill" values="#ffffff00;#ffffff00;#ffffff00;#ffffff00;#ffffff00;#ffffff;#ffffff00;#ffffff00;#ffffff00;#ffffff00;" dur="2s" repeatCount="indefinite"/></circle>'
                )
            );
    }

    // Final SVG code for the NFT
    function generateFinalSvg(
        uint randomSeed1,
        uint randomSeed2,
        uint randomSeed3,
        uint randomSeed4
    ) public pure returns (string memory) {
        bytes memory backgroundCode = abi.encodePacked(
            // SVG SIZE
            '<rect width="1250" height="1250" fill="',
            backgroundColors(randomSeed1 % 3),
            '" />'
        );

        // Which line will contain the circle
        uint circleLocation = (randomSeed1 % 3) + 1;

        // SVG opening and closing tags, background color + 3 lines generated
        string memory finalSvg = string(
            abi.encodePacked(
                '<svg viewBox="0 0 1250 1250" xmlns="http://www.w3.org/2000/svg">',
                backgroundCode,
                generateLineSvg(1, randomSeed1),
                generateLineSvg(2, randomSeed2),
                generateLineSvg(3, randomSeed3),
                generateLineSvg(4, randomSeed4),
                drawCircle(circleLocation),
                "</svg>"
            )
        );

        // console.log("Final Svg: ", string(finalSvg));
        return finalSvg;
    }

    // Generate token URI with all the SVG code, to be stored on-chain
    function tokenURI(uint tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(tokenId));

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "Shade #',
                                uint2str(tokenId),
                                '", "description": "The Shade collection an assortment of 111 fully on-chain, randomly generated, shades", "attributes": "", "image":"data:image/svg+xml;base64,',
                                Base64.encode(bytes(tokenIdToSvg[tokenId])),
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    // Mint new Balls of Art
    function mintNinetyNFT(uint tokenId) public payable {
        // Require token ID to be between 1 and maxSupply (111)
        require(tokenId > 0 && tokenId <= maxSupply, "Token ID invalid");

        // Make sure the amount of ETH is equal or larger than the minimum mint price
        require(msg.value >= mintPrice, "Not enough ETH sent");

        uint randomSeed1 = uint(
            keccak256(abi.encodePacked(block.basefee, block.timestamp))
        );
        uint randomSeed2 = uint(
            keccak256(abi.encodePacked(block.timestamp, msg.sender))
        );
        uint randomSeed3 = uint(
            keccak256(abi.encodePacked(msg.sender, block.timestamp))
        );
        uint randomSeed4 = uint(
            keccak256(abi.encodePacked(msg.sender, block.timestamp))
        );
    

        tokenIdToSvg[tokenId] = generateFinalSvg(
            randomSeed1,
            randomSeed2,
            randomSeed3,
            randomSeed4
        );

        // Mint token
        _mint(msg.sender, tokenId);

        // Increase minted tokens counter
        ++totalSupply;

        emit ShadeCreated(tokenId);
    }

    // Withdraw funds from the contract
    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    // From: https://stackoverflow.com/a/65707309/11969592
    function uint2str(uint _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}