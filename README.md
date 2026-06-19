# pjsua Container

This repository builds a container image that packages the `pjsua` command-line SIP user agent from PJSIP.

Published image:

```text
ghcr.io/stell0/pjsua:latest
```

## Pull the image

```sh
podman pull ghcr.io/stell0/pjsua:latest
```

## Prepare audio files

Create a directory for input and output WAV files:

```sh
mkdir -p audio
```

Place the prompt you want to play at `audio/prompt.wav`. The example below writes the recorded call audio to `audio/recording.wav`.

## Run an agent

The container entrypoint is `pjsua`, so any arguments after the image name are passed directly to the SIP client.

```sh
podman run --rm -it \
  --network host \
  -v "$PWD/audio:/audio" \
  ghcr.io/stell0/pjsua:latest \
  --id sip:agent01@pbx.example.com \
  --registrar sip:pbx.example.com \
  --proxy 'sip:proxy.example.com;lr' \
  --realm '*' \
  --username agent01 \
  --password '<sip-password>' \
  --null-audio \
  --play-file /audio/prompt.wav \
  --rec-file /audio/recording.wav \
  --auto-rec \
  --use-cli \
  --cli-telnet-port 2323 \
  --no-cli-console
```

Replace the SIP account, registrar, proxy, username, and password values with the credentials from your PBX. Remove `--proxy` if the SIP endpoint should talk directly to the registrar.

## Notes

- `--network host` is the simplest option for SIP and RTP on Linux.
- `--proxy 'sip:proxy.example.com;lr'` routes SIP requests through the proxy while keeping the registrar/account domain separate.
- `--null-audio` disables live audio hardware and uses files instead, so the example does not require a sound device from the host.
- `--play-file` should point to a WAV file that `pjsua` can decode.
- `--rec-file` is created inside the mounted `/audio` directory on the host.
- `--use-cli --cli-telnet-port 2323 --no-cli-console` enables the telnet CLI without attaching an interactive CLI to the terminal.

## Optional short image name

If you want to use a short local alias such as `pjsua-agent` in your commands:

```sh
podman tag ghcr.io/stell0/pjsua:latest localhost/pjsua-agent:latest
```

Then you can replace `ghcr.io/stell0/pjsua:latest` with `localhost/pjsua-agent:latest` in the run command.
