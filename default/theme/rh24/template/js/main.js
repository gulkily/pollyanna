import * as THREE from 'three'
import {VRButton} from 'VRButton';
// import { TextGeometry } from 'TextGeometry';

// init
const width = 640, height = 480;
const camera = new THREE.PerspectiveCamera( 70, width / height, 0.01, 10 );
camera.position.y = 1.2;

const scene = new THREE.Scene();

const renderer = new THREE.WebGLRenderer( { antialias: true } );
renderer.xr.enabled = true;
document.body.appendChild(VRButton.createButton(renderer));

renderer.setSize( width, height );
renderer.setAnimationLoop( animation );
document.body.appendChild( renderer.domElement );

const markerGeometry = new THREE.BoxGeometry( 0.01, 0.01, 0.04 );
const markerMaterial = new THREE.MeshNormalMaterial();
const markerEntity = new THREE.Mesh( markerGeometry, markerMaterial );
markerEntity.position.x = 0.2;
markerEntity.position.y = 1.2;
markerEntity.position.z = -0.5;
scene.add( markerEntity );

const WHITEBOARD_PIXELS_PER_METER = 400;  // changing this woulld currently cause board to shrink/stretch
const whiteboardYPosition = 1;
const whiteboardZPosition = -0.35;

let whiteboardMesh;
let ctx;
let whiteboardCanvas;
let canvasTexture;
// connect html canvas element to THREE scene
{
    whiteboardCanvas = document.createElement("canvas");
    whiteboardCanvas.setAttribute("id", "whiteboardCanvas");
    whiteboardCanvas.height=640;
    whiteboardCanvas.width=1024;
    window.whiteboardCanvas = whiteboardCanvas;
    document.body.appendChild(whiteboardCanvas);
    
    ctx = whiteboardCanvas.getContext("2d");
    ctx.beginPath();
    ctx.rect(0, 0, whiteboardCanvas.width, whiteboardCanvas.height);
    ctx.fillStyle = "#06A3C5";
    ctx.fill();
    ctx.closePath();

    ctx.font = "30px arial";
    ctx.fillStyle = "#000000";
    ctx.strokeText("Hi World", 10, 50);

    canvasTexture = new THREE.CanvasTexture(whiteboardCanvas)
    window.canvasTexture = canvasTexture;

    const geometry = new THREE.PlaneGeometry( whiteboardCanvas.width / WHITEBOARD_PIXELS_PER_METER, whiteboardCanvas.height / WHITEBOARD_PIXELS_PER_METER );
    const material = new THREE.MeshBasicMaterial( {color: 0xffffff, side: THREE.DoubleSide, map: canvasTexture} );
    whiteboardMesh = new THREE.Mesh( geometry, material );
    whiteboardMesh.position.set( 0, whiteboardYPosition, whiteboardZPosition );
    scene.add( whiteboardMesh );
}

let bActive = false;
let lastX, lastY;
const canvasXOffset = whiteboardCanvas.width / 2; // canvas zero is at left not center
const canvasYOffset = whiteboardCanvas.height / 2;
const pressureFactor = 50;
// call function without arguments to stop drawing
function drawBoardAt(planeX, planeY, planeZ) {
    if (!planeX || !planeY) {
        bActive = false;
        lastX = lastY = null;
        return
    }
    // convert x/y from format used in THREE.plane to format used in canvas 
    const x = (planeX * WHITEBOARD_PIXELS_PER_METER) + canvasXOffset;  // canvas x=0 is at left
    const y = canvasYOffset - (planeY * WHITEBOARD_PIXELS_PER_METER);  // canvas y=0 is at top
    if (bActive) {
        // a path is active, draw a bit
        ctx.lineWidth = Math.max(1, 1 - planeZ*pressureFactor);  // planeZ is assumed to be negative
        ctx.lineTo(x, y); // Draw a line to (150, 100)
        ctx.stroke(); // Render the path
        canvasTexture.needsUpdate = true;
    }
    else {
        // new line segment is starting
        bActive = true;
        ctx.beginPath(); // Start a new path
        ctx.moveTo(x, y); // Move the pen to (30, 50)
    }
    lastX = x;
    lastY = y;
}

const HAND_INDEX = 0;
const hand = renderer.xr.getHand(HAND_INDEX);
function animation( time ) {
    window.hand = hand;
    
    const indexFinger = hand.children[9];
    if (indexFinger) {
        markerEntity.position.copy(indexFinger.position);
        markerEntity.position.z += 0.02; // half the z-depth of marker

        const boardLocalVector = whiteboardMesh.worldToLocal(indexFinger.position)

        if (boardLocalVector.z < 0) {
            drawBoardAt(boardLocalVector.x, boardLocalVector.y, boardLocalVector.z);  // draws on the second iteration onward
        }
        else {
            drawBoardAt();  // clear the current line
        }
    }

	renderer.render( scene, camera );
}
