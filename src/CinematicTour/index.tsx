import React from "react";
import { AbsoluteFill, Sequence, staticFile } from "remotion";
import { z } from "zod";
import { ClosingCard } from "../PropertyReel/ClosingCard";
import { FlashCut } from "./FlashCut";
import { ParallaxShot } from "./ParallaxShot";
import { Shot } from "./Shot";
import { VideoShot } from "./VideoShot";

export const cinematicTourSchema = z.object({
  location: z.string(),
  agentName: z.string(),
  brokerage: z.string(),
  contact: z.string().optional(),
});

const GOLD = "contrast(1.12) saturate(1.2) brightness(1.02) sepia(0.12) hue-rotate(-6deg)";
const NEUTRAL_WARM = "contrast(1.05) saturate(1.08) brightness(1.04) sepia(0.05)";
const DUSK_VIGNETTE =
  "radial-gradient(ellipse at center, rgba(0,0,0,0) 45%, rgba(10,15,35,0.35) 100%), linear-gradient(to top, rgba(20,10,0,0.35), rgba(0,0,0,0) 35%)";
const SOFT_VIGNETTE = "linear-gradient(to top, rgba(10,5,0,0.28), rgba(0,0,0,0) 42%)";

// --- Beat durations (frames @ 30fps) -----------------------------------
const HOOK = 39; // 1.3s
const ENTRADA = 69; // 2.3s
const PRIMERA_VISTA = 75; // 2.5s
const RECORRIDO_HALL = 54; // 1.8s
const RECORRIDO_VID1 = 45; // 1.5s
const RECORRIDO_VID2 = 60; // 2.0s
const RECORRIDO_VID3 = 48; // 1.6s
const DETALLE = 60; // 2.0s
const HERO = 78; // 2.6s
const CIERRE = 60; // 2.0s

export const cinematicTourDurationInFrames =
  HOOK +
  ENTRADA +
  PRIMERA_VISTA +
  RECORRIDO_HALL +
  RECORRIDO_VID1 +
  RECORRIDO_VID2 +
  RECORRIDO_VID3 +
  DETALLE +
  HERO +
  CIERRE;

export const CinematicTour: React.FC<z.infer<typeof cinematicTourSchema>> = ({
  location,
  agentName,
  brokerage,
  contact,
}) => {
  let t = 0;
  const hookStart = t;
  t += HOOK;
  const entradaStart = t;
  t += ENTRADA;
  const primeraVistaStart = t;
  t += PRIMERA_VISTA;
  const hallStart = t;
  t += RECORRIDO_HALL;
  const vid1Start = t;
  t += RECORRIDO_VID1;
  const vid2Start = t;
  t += RECORRIDO_VID2;
  const vid3Start = t;
  t += RECORRIDO_VID3;
  const detalleStart = t;
  t += DETALLE;
  const heroStart = t;
  t += HERO;
  const cierreStart = t;
  t += CIERRE;

  return (
    <AbsoluteFill style={{ backgroundColor: "#000" }}>
      {/* HOOK: extreme close-up on the golden door, whipping back to reveal the house */}
      <Sequence from={hookStart} durationInFrames={HOOK}>
        <Shot
          src={staticFile("fotos/facade.jpg")}
          durationInFrames={HOOK}
          from={{ scale: 3.2, x: 0, y: 0 }}
          to={{ scale: 1.15, x: 0, y: 0 }}
          focalPoint="center 38%"
          grade={GOLD}
          exitBlur={12}
          exitBlurFrames={8}
        />
      </Sequence>

      {/* ENTRADA: aerial establishing shot, truck + push-in */}
      <Sequence from={entradaStart} durationInFrames={ENTRADA}>
        <Shot
          src={staticFile("fotos/aerial.jpg")}
          durationInFrames={ENTRADA}
          from={{ scale: 1, x: 2, y: 0.5 }}
          to={{ scale: 1.13, x: -2, y: -1 }}
          focalPoint="center 45%"
          grade={GOLD}
          vignette={SOFT_VIGNETTE}
          entryBlur={12}
          entryBlurFrames={8}
          exitBlur={12}
          exitBlurFrames={8}
        />
      </Sequence>

      {/* PRIMERA VISTA: facade reveal, dolly-in with a slight rise */}
      <Sequence from={primeraVistaStart} durationInFrames={PRIMERA_VISTA}>
        <Shot
          src={staticFile("fotos/facade.jpg")}
          durationInFrames={PRIMERA_VISTA}
          from={{ scale: 1, x: 0, y: 0 }}
          to={{ scale: 1.14, x: 0, y: -1.6 }}
          focalPoint="center 38%"
          grade={GOLD}
          vignette={DUSK_VIGNETTE}
          entryBlur={12}
          entryBlurFrames={8}
          exitBlur={10}
          exitBlurFrames={7}
        />
      </Sequence>

      {/* RECORRIDO 1: hall de doble altura, parallax 2.5D push-in */}
      <Sequence from={hallStart} durationInFrames={RECORRIDO_HALL}>
        <ParallaxShot
          src={staticFile("fotos/interior-hall.jpg")}
          durationInFrames={RECORRIDO_HALL}
          focalPoint="center 48%"
          grade={NEUTRAL_WARM}
          bgScale={[1.05, 1.14]}
          fgScale={[1.12, 1.34]}
          foregroundCoverage={0.45}
          blurAmount={10}
          entryBlurFrames={8}
          exitBlurFrames={6}
        />
      </Sequence>

      {/* RECORRIDO 2: clip real - caminata por sala/galeria */}
      <Sequence from={vid1Start} durationInFrames={RECORRIDO_VID1}>
        <VideoShot
          src={staticFile("videos/VID-20260911-WA0038.mp4")}
          durationInFrames={RECORRIDO_VID1}
          trimBeforeSeconds={1.5}
          grade={NEUTRAL_WARM}
        />
      </Sequence>

      {/* RECORRIDO 3: clip real - cocina, caminata natural */}
      <Sequence from={vid2Start} durationInFrames={RECORRIDO_VID2}>
        <VideoShot
          src={staticFile("videos/VID_20260911_185605.mp4")}
          durationInFrames={RECORRIDO_VID2}
          trimBeforeSeconds={1.2}
          grade={NEUTRAL_WARM}
        />
      </Sequence>

      {/* RECORRIDO 4: clip real - bar/lounge, pan sintetico sobre plano estatico */}
      <Sequence from={vid3Start} durationInFrames={RECORRIDO_VID3}>
        <VideoShot
          src={staticFile("videos/VID_20260911_185435.mp4")}
          durationInFrames={RECORRIDO_VID3}
          trimBeforeSeconds={4.0}
          grade={NEUTRAL_WARM}
          panFrom={68}
          panTo={32}
        />
      </Sequence>

      {/* DETALLES: espejo de agua / fachada, parallax */}
      <Sequence from={detalleStart} durationInFrames={DETALLE}>
        <ParallaxShot
          src={staticFile("fotos/facade-pond.jpg")}
          durationInFrames={DETALLE}
          focalPoint="center 55%"
          grade={GOLD}
          bgScale={[1.02, 1.08]}
          fgScale={[1.08, 1.24]}
          foregroundCoverage={0.4}
          blurAmount={10}
          entryBlurFrames={8}
          exitBlurFrames={8}
        />
      </Sequence>

      {/* MOMENTO HERO: piscina + jacuzzi, truck + push-in lento */}
      <Sequence from={heroStart} durationInFrames={HERO}>
        <Shot
          src={staticFile("fotos/piscina.jpg")}
          durationInFrames={HERO}
          from={{ scale: 1, x: -1.5, y: 0 }}
          to={{ scale: 1.13, x: 1.5, y: -1 }}
          focalPoint="center 70%"
          grade={GOLD}
          vignette={SOFT_VIGNETTE}
          entryBlur={10}
          entryBlurFrames={8}
        />
      </Sequence>

      {/* CIERRE: tarjeta final con flash calido en el corte */}
      <Sequence from={cierreStart} durationInFrames={CIERRE}>
        <ClosingCard
          durationInFrames={CIERRE}
          location={location}
          agentName={agentName}
          brokerage={brokerage}
          contact={contact}
        />
      </Sequence>
      <Sequence from={heroStart + HERO - 6} durationInFrames={12}>
        <FlashCut totalFrames={12} peakFrame={6} />
      </Sequence>
    </AbsoluteFill>
  );
};
