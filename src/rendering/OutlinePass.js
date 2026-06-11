// Inverted-hull outlines: every outlined mesh gets a slightly inflated
// back-face shell as a child, so it inherits all transforms (including the
// live phenotype scaling). Cheap, stylized, ports to a Godot shader pass.

import * as THREE from "three";

const outlineMaterialCache = new Map();

// key: string used for cache lookup; colorValue: the actual color to construct
// with (may be a THREE.Color, hex number, or CSS string).
function getOutlineMaterial(key, colorValue) {
  if (colorValue === undefined) {
    // Legacy single-arg call: key is also the color value.
    colorValue = key;
    key = String(key);
  }
  if (!outlineMaterialCache.has(key)) {
    outlineMaterialCache.set(
      key,
      new THREE.MeshBasicMaterial({ color: colorValue, side: THREE.BackSide, toneMapped: false })
    );
  }
  return outlineMaterialCache.get(key);
}

export function addOutline(target, { thickness = 0.035, color = 0x07090c } = {}) {
  const targets = [];
  target.traverse((obj) => {
    if (obj.isMesh && !obj.userData.isOutline && !obj.userData.noOutline) targets.push(obj);
  });
  for (const mesh of targets) {
    // Derive shell color from source mesh material when available.
    // Multiply by 0.3 to get a dark-but-tinted outline instead of flat black.
    // Fall back to the caller-supplied default color if .color is absent.
    let shellColor;
    if (mesh.material && mesh.material.color) {
      shellColor = mesh.material.color.clone().multiplyScalar(0.3);
    } else {
      shellColor = color;
    }
    // Cache by hex string so meshes sharing the same hue share one material.
    const cacheKey = shellColor instanceof THREE.Color
      ? "#" + shellColor.getHexString()
      : String(shellColor);
    const shell = new THREE.Mesh(mesh.geometry, getOutlineMaterial(cacheKey, shellColor));
    shell.userData.isOutline = true;
    shell.raycast = () => {};
    shell.scale.setScalar(1 + thickness);
    mesh.add(shell);
  }
  return target;
}

export function removeOutlines(target) {
  const trash = [];
  target.traverse((obj) => {
    if (obj.userData.isOutline) trash.push(obj);
  });
  for (const shell of trash) shell.parent?.remove(shell);
}
