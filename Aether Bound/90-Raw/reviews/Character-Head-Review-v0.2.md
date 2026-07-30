# Character Head/Bust Review v0.2 — humano base, cabeza y busto (M9/M10)

> **Fuente RAW del director (Boris), 2026-07-10.** Depositado verbatim (review
> con rol Lead Art Director/PM sobre capturas `anatomy_face.png` /
> `anatomy_face_34.png` de M9-r1). No se edita. Checklist vivo:
> [[Task-Board]] §C6.

## Overall Assessment

The current implementation reads as an early blockout with flat cel-style
shading running in-engine. The overall stylized direction is compatible with a
low-poly production target, but the head deviates significantly from the
approved concept in hairstyle, hair color, facial structure, and expression,
and the visible upper body omits the concept's defining costume elements
(layered hood/cowl, shoulder wrap). The facial markings (green paint stripes),
a key identity feature in the concept, are absent. Both provided views are
framed from the chest up, so proportions below the torso could not be
verified. **Verdict: Needs Revision.**

## Critical Issues

1. **Hair color and hairstyle deviate from concept.** The concept shows short,
   textured light-brown/dark-blond hair swept up and back. The implementation
   uses saturated red/orange hair with a large angular wedge shape projecting
   forward-left of the skull, plus a detached curl mass over the right ear.
   - Impact: hair color is a primary character-recognition attribute. A
     red-haired character is a different character at gameplay distance. The
     floating wedge geometry also reads as a hat or foreign object.
   - Required fix: rebuild the hair blockout to match the concept: short
     cropped sides, volume swept upward and back, color shifted to the
     approved light-brown/blond value. Remove the forward-projecting wedge and
     the disconnected ear-side curl.

2. **Facial paint markings are missing.** The concept clearly shows green
   diagonal stripes across the forehead/brow and left cheek, plus a marking on
   the upper arm.
   - Impact: identity-defining elements, likely tied to lore/faction
     readability. Trivially cheap to represent even at blockout stage.
   - Required fix: add the green markings in the approved positions: forehead
     diagonal, left cheek diagonal, upper-arm stripe.

## High Priority Issues

3. **Costume layer hierarchy absent on visible torso.** The concept shows a
   layered hood/cowl with a torn-edge shoulder wrap and leather shoulder
   piece; the implementation shows a bare torso with panel seam lines only.
   - Impact: clothing silhouette changes shoulder/neck silhouette, rig
     collision volumes and equipment attachment planning.
   - Required fix: block in the cowl and shoulder-wrap volumes as simple
     primitives now — **or**, if the bare torso is an intentional base-body
     pass for a modular equipment system, document that in the PR description.

4. **Facial structure deviation:** implementation face is longer and narrower
   with a heavy vertical chin/jaw seam and a small pursed mouth. Concept
   depicts a broader, squarer jaw, visible stubble, prominent smile with
   teeth, stronger cheekbone definition.
   - Required fix: widen the jaw, reduce mid-face length, correct mouth width
     and default expression toward the concept's neutral-friendly read.
     Stubble can defer to texture; the jaw mass cannot.

5. **Brow and eye treatment off-model.** Implementation eyes are large, round,
   high-contrast white circles with thick arched outline brows. Concept eyes
   are narrower, more naturalistic within the stylization, lower-set
   straighter brows.
   - Impact: round saucer eyes push toward a cartoon register, conflicting
     with the grounded-fantasy direction.
   - Required fix: reduce sclera visibility, narrow the eye aperture, lower
     and straighten the brows.

## Medium Priority Issues

6. **Neck and clavicle definition.** Overlong cylindrical neck with abrupt
   trapezius transition; concept implies a shorter, thicker neck partially
   occluded by the cowl.
   - Required fix: shorten the neck slightly, blend the trapezius slope;
     re-check once the cowl blockout is in place.

7. **Ear placement/scale.** Ears sit high and read small; concept ears align
   roughly brow-to-nose.
   - Required fix: lower and scale ears to the brow-to-nose band after face
     proportions are corrected.

## Low Priority Issues

8. **Held prop (dark box/device in right hand)** has no counterpart in the
   concept crop. Link its approved reference or remove from the review build.

9. **Skin tone warmer/more saturated** than the concept's cooler, paler
   complexion. A/B the albedo under neutral light; adjust base value if the
   delta persists.

## Positive Findings

- Flat cel-shaded rendering approach is consistent with the aesthetic target
  and reads correctly in-engine.
- Low-poly panelization of the torso with clean seam lines is appropriate and
  suggests sensible topology planning.
- Overall bust proportions (head-to-shoulder ratio at this framing) are in a
  plausible range.
- The asset is already integrated and rendering in Godot with environment
  lighting — correct workflow order for evaluating readability.

## Production Risk

- Rigging/animation: elongated neck and off-model jaw/mouth geometry would
  require re-skinning and facial rig rework if corrected after rig binding.
- Modular equipment: absence of cowl/shoulder-wrap blockout leaves attachment
  points and shoulder clearances undefined.
- Gameplay readability: wrong hair color and missing face paint break
  recognition at distance.
- Art direction drift: the round-eye cartoon register conflicts with the
  grounded-fantasy bible and would propagate to subsequent characters.
- Review coverage: no full-body/turnaround shots submitted with the bust
  captures; final approval cannot be granted on a bust view.

## Final Score

- Concept Fidelity: **4 / 10**
- Production Readiness: **5 / 10**
- Technical Execution: **6 / 10**
- **Overall: 5 / 10** — the pipeline execution is sound; the likeness is not.
  Correct the head (hair, face, markings) and block in the costume layers,
  then resubmit with full-body turnaround captures.
