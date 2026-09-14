import React from "react";
import { AbsoluteFill, Sequence, staticFile } from "remotion";
import { z } from "zod";
import { ClosingCard } from "./ClosingCard";
import { KenBurnsScene } from "./KenBurnsScene";

export const propertyReelSchema = z.object({
  location: z.string(),
  agentName: z.string(),
  brokerage: z.string(),
  contact: z.string().optional(),
});

// Warm golden-hour grade shared by the exterior/lifestyle shots.
const GOLDEN_GRADE =
  "contrast(1.12) saturate(1.2) brightness(1.02) sepia(0.12) hue-rotate(-6deg)";
const DUSK_VIGNETTE =
  "radial-gradient(ellipse at center, rgba(0,0,0,0) 45%, rgba(10,15,35,0.35) 100%), linear-gradient(to top, rgba(20,10,0,0.35), rgba(0,0,0,0) 35%)";

const FPS = 30;
const AERIAL_FRAMES = 2 * FPS; // 0-2s: escena 1, aereo estableciendo el lote
const FACADE_FRAMES = 2 * FPS; // 2-4s: escena 2, acercamiento a la puerta dorada
const INTERIOR_FRAMES = 1.5 * FPS; // 4-5.5s
const POOL_FRAMES = 1.5 * FPS; // 5.5-7s
const CLOSING_FRAMES = 1 * FPS; // 7-8s

export const propertyReelDurationInFrames =
  AERIAL_FRAMES + FACADE_FRAMES + INTERIOR_FRAMES + POOL_FRAMES + CLOSING_FRAMES;

export const PropertyReel: React.FC<z.infer<typeof propertyReelSchema>> = ({
  location,
  agentName,
  brokerage,
  contact,
}) => {
  return (
    <AbsoluteFill style={{ backgroundColor: "#000" }}>
      {/* Escena 1: toma aerea estableciendo el lote (dron real, DJI) */}
      <Sequence durationInFrames={AERIAL_FRAMES}>
        <KenBurnsScene
          src={staticFile("fotos/aerial.jpg")}
          durationInFrames={AERIAL_FRAMES}
          startScale={1}
          endScale={1.14}
          focalPoint="center 45%"
          grade={GOLDEN_GRADE}
          vignette="linear-gradient(to top, rgba(10,5,0,0.25), rgba(0,0,0,0) 40%)"
          fadeIn={false}
        />
      </Sequence>

      {/* Escena 2: fachada al anochecer, dron acercandose a la puerta dorada */}
      <Sequence from={AERIAL_FRAMES} durationInFrames={FACADE_FRAMES}>
        <KenBurnsScene
          src={staticFile("fotos/facade.jpg")}
          durationInFrames={FACADE_FRAMES}
          startScale={1}
          endScale={1.16}
          focalPoint="center 38%"
          grade={GOLDEN_GRADE}
          vignette={DUSK_VIGNETTE}
        />
      </Sequence>

      {/* Escena 3: match cut hacia el hall de doble altura */}
      <Sequence from={AERIAL_FRAMES + FACADE_FRAMES} durationInFrames={INTERIOR_FRAMES}>
        <KenBurnsScene
          src={staticFile("fotos/interior-hall.jpg")}
          durationInFrames={INTERIOR_FRAMES}
          startScale={1}
          endScale={1.14}
          focalPoint="center 48%"
          grade="contrast(1.05) saturate(1.08) brightness(1.05) sepia(0.06)"
        />
      </Sequence>

      {/* Escena 4: dolly-in a la piscina y jacuzzi */}
      <Sequence
        from={AERIAL_FRAMES + FACADE_FRAMES + INTERIOR_FRAMES}
        durationInFrames={POOL_FRAMES}
      >
        <KenBurnsScene
          src={staticFile("fotos/piscina.jpg")}
          durationInFrames={POOL_FRAMES}
          startScale={1}
          endScale={1.12}
          focalPoint="center 70%"
          grade={GOLDEN_GRADE}
          vignette="linear-gradient(to top, rgba(10,5,0,0.3), rgba(0,0,0,0) 40%)"
        />
      </Sequence>

      {/* Escena 5: cierre estatico de noche con texto */}
      <Sequence
        from={AERIAL_FRAMES + FACADE_FRAMES + INTERIOR_FRAMES + POOL_FRAMES}
        durationInFrames={CLOSING_FRAMES}
      >
        <ClosingCard
          durationInFrames={CLOSING_FRAMES}
          location={location}
          agentName={agentName}
          brokerage={brokerage}
          contact={contact}
        />
      </Sequence>
    </AbsoluteFill>
  );
};
