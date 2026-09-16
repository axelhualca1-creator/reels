# Prompt Seedance — Kit Práctico (EbookUGC)

Guion de prompts para generar clips con Seedance (o Runway, Kling, Sora u
otra herramienta de video generativo por IA). El clip se genera por
separado y luego se coloca en `public/videos/` para que la composición
`EbookUGC` de Remotion (`src/EbookUGC/AuthorScene.tsx`) lo use
automáticamente como fondo de la escena de autoridad ("cita + autora").

Si el archivo no existe, `AuthorScene` sigue usando el fondo plano de
siempre — no hace falta tocar código, solo colocar el video generado en
la ruta indicada.

## Escena — Transición cinematográfica de éxito inmobiliario

**Composición destino:** `EbookUGC` → `AuthorScene`
**Archivo esperado:** `public/videos/awards-reveal.mp4`
**Formato:** vertical 9:16, 1080×1920 (o más alto y luego recortar/escalar)
**Duración objetivo:** ~5-6 segundos (la escena dura 6s en el video; si el
clip generado es más largo, simplemente se recorta al llegar a los 6s)
**Audio:** no hace falta (el video se reproduce muteado; la música y los
efectos ya están puestos en la composición)

### Prompt (inglés, listo para pegar en la herramienta de generación)

```
Create a cinematic real-estate success transition. Start with a
close-up shot focused on the ebook held by the woman. The camera
slowly pulls back and smoothly moves away from the ebook, revealing
more of the environment. As the camera continues pulling back,
smoothly transition the focus from the ebook to the entire room,
revealing multiple prestigious real-estate sales awards, trophies,
certificates, plaques, and recognitions displayed around her,
symbolizing her success as an outstanding real-estate salesperson.

Use a slow, elegant camera movement with realistic depth of field,
natural cinematic lighting, subtle lens blur, and a premium
corporate-real-estate atmosphere. The transition should feel
continuous and seamless, as if the camera is physically moving
backward through the scene. Keep the woman and the original
environment visually consistent. Make the awards progressively
become the main visual focus as the camera pulls away.

High-end commercial cinematography, realistic motion, smooth focus
transition, sophisticated, inspiring, professional, 4K.

Vertical 9:16 aspect ratio, 5-6 second single continuous shot.
```

### Al recibir el clip generado

1. Guárdalo como `public/videos/awards-reveal.mp4`.
2. Corre `npm run dev` y abre la composición `EbookUGC` en Remotion
   Studio — la escena de la cita ("La confianza no se gana...") debería
   mostrar el video de fondo con un degradado oscuro para que el texto
   se siga leyendo bien.
3. Si el encuadre del rostro/libro no cae bien detrás del texto, ajusta
   el `objectPosition` del video en `AuthorScene.tsx`.

## Escena — (pendiente)

## Escena — (pendiente)
